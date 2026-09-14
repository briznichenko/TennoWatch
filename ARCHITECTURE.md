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

Callers never receive data back from a write call. They observe the result
via `@Query`, same as any other change to the store.

## Rule 2 — every write path ends in `context.save()`

`@ModelActor`-generated contexts default `autosaveEnabled = false`. If a
write path forgets to call `context.save()`, the mutation sits in the
actor's context, the store is never touched, and **`@Query` never sees it** —
the UI just looks stale with no error to explain why.

`@Query`'s cross-context refresh depends on both contexts (the main
context feeding `@Query`, and the `@ModelActor`'s context) belonging to the
*same* `ModelContainer` instance — true here since `AppDependencies` builds
`DefaultPersistencyService` from the exact `ModelContainer` passed to
`.modelContainer(_:)` in `WarframeListenerApp`. Don't split that: a second
`ModelContainer` pointed at the same store (even the same file) breaks the
change-notification path `@Query` relies on.

If a future change adds a write path and the UI doesn't refresh after it,
check these two things first, in this order: is the container the same
instance, and does every branch through `perform` end in `.save()`.
