# Persistence architecture

The SwiftData layer is deliberately asymmetric: **reads are coupled to
SwiftData, writes are abstracted behind repositories.** This isn't an
oversight to "fix" toward one consistent style — the two halves optimize for
different things and would fight each other if unified.

## Reads: `@Model` types are the domain models

There's no plain-struct mirror of `MasteryCatalogDataModel`,
`ProfileDataModel`, `MasteryItemDataModel`, etc. Views query the `@Model`
types directly with `@Query` and pass the fetched instances straight down to
child views. Business logic that used to live on a mirror struct
(`rank`, `masteryState`, `earnedMasteryXP`, `countText`, …) now lives as
computed extensions directly on the `@Model` class.

This is deliberately coupled to SwiftData because `@Query` is what makes the
UI reactive for free: a view that reads a `@Model` property is automatically
invalidated when that property changes, with no manual "refresh" plumbing.
Decoupling reads behind a repository would mean rebuilding that reactivity
by hand (polling, `NotificationCenter`, a Combine publisher wrapping SwiftData) —
strictly worse for a single-persistence-backend app.

## Writes: everything goes through a repository backed by one `@ModelActor`

Views never write. Every mutation — background sync, the bundled-catalog
seed, profile refresh — goes through `ProfileRepository` / `CatalogRepository`,
both backed by the single `DefaultPersistencyService` (`@ModelActor`) built
once in `AppDependencies`. This is deliberately *not* coupled to SwiftData:
the repository protocols expose intent ("sync the profile", "reconcile the
catalog"), not SwiftData types, so the persistence backend behind them is
swappable and the repositories are testable against a fake without touching
`ModelContext` at all.

## Rule 1 — never return a `@Model` across the actor boundary

`@Model` instances aren't `Sendable`; they're bound to the `ModelContext`
that fetched them. A repository method can't fetch a `ProfileDataModel`
inside its `@ModelActor` and hand it back to a `@MainActor` caller — that's a
data race waiting to happen, and the compiler will refuse it under Swift 6
strict concurrency the moment the type isn't `Sendable`.

So repository methods are intent-level and `Void`-returning
(`syncProfile(withPlayerId:)`, `syncCatalog()`). Any read a repository needs
internally (e.g. "is the stored profile fresh?") happens *inside*
`persistencyService.perform { context in ... }` and only returns `Sendable`
scalars if the result is needed outside the closure. `CatalogSyncService`
is declared `Sendable` for the same reason — it's captured into that
`@Sendable` closure, so the compiler needs proof it holds no state that could
race.

Callers never receive a `@Model` back from a write call. Where a caller
genuinely needs the result of a sync (see Rule 3), the repository returns a
plain `Sendable` snapshot struct — never the model itself.

## Rule 2 — every write path ends in `context.save()`

`@ModelActor`-generated contexts default `autosaveEnabled = false`. If a
write path forgets to call `context.save()`, the mutation sits in the
actor's context and the store is never touched. This is necessary for
`@Query` to see a change at all, but — see Rule 3 — it isn't sufficient.

## Rule 3 — `@Query` does not reliably observe writes to relationship-nested
## entities made through a separate `ModelActor` context

This is the one that cost real debugging time, so it's recorded precisely.
Confirmed empirically (uninstall → fresh launch → sync → inspect both the
live UI and the SQLite store directly):

- `@Query`'s live refresh **does** reliably fire for inserts/deletes of the
  *queried* entity type, and for scalar-attribute changes on that same
  directly-queried entity (`MasteryCatalogDataModel.lastSyncedAt` update was
  observed live, reliably, across repeated tests).
- `@Query`'s live refresh **does not** reliably fire for mutations to
  entities reached only via a relationship from the queried root
  (`MasteryCatalogDataModel.items[].masteryItems[].profileItem`,
  `....nonItemSources[].sources[].isMastered`) when those mutations are made
  by a *different* `ModelContext` (the `@ModelActor`'s). The store itself is
  correct — reading it directly via `sqlite3`, or relaunching the app fresh
  (a brand-new `ModelContext` that hasn't cached anything yet), always shows
  the right data. It's specifically an already-materialized `@Query` result,
  live in an already-running session, that goes stale and stays stale.
- None of the usual workarounds fixed it reliably: `.id()`-forcing the
  `@Query`-owning view to be torn down and rebuilt, `ModelContext.rollback()`
  on the environment's context, registering additional unrelated `@Query`s
  for the nested entity types, deferring the refresh to `.onChange` instead
  of inline after the `await` — all either had no effect or worked
  inconsistently across otherwise-identical runs. This looks like a genuine
  platform limitation (tested on iOS 26.5 Simulator) rather than something
  fixable from the view layer.

**The actual fix**: for data whose correctness depends on a background sync
mutating nested relationships, don't read it via `@Query` relationship
traversal at all. `CatalogRepository.fetchSummary()` computes a `MasterySummary`
(a plain `Sendable` struct — counts, per-item mastery snapshots) *inside* the
`ModelActor`'s `perform` closure, immediately after the sync that produced
it, so it's built from data the actor knows is current. `MasteryViewModel`
holds that summary directly (`@Observable` property mutation — ordinary,
reliable SwiftUI reactivity, not `@Query`), and `MasteryView` /
`MasteryCategoryDetailView` read counts and per-item state from it, falling
back to the live `@Model` only when no summary has landed yet. The `@Model`
references themselves (`CatalogContainerModel`, `MasteryItemDataModel`, …)
are still used for navigation and for anything that doesn't change after
creation (name, category, max rank) — just not for anything a sync mutates.

If a future screen shows stale data after a confirmed-successful background
sync (check the SQLite store directly to confirm — `sqlite3 <store path>
"SELECT ..."` — before assuming the sync itself is broken), this is almost
certainly why. The fix is the same: compute a `Sendable` snapshot inside the
actor at write time rather than trusting a live `@Query` relationship read.
