# Layer: Repositories

`WarframeListener/Repositories/` — the boundary every ViewModel talks to.
One protocol + one default implementation per data domain; this is where
cache policy and "network vs. local" decisions live, kept out of both
ViewModels and the networking/persistency layers.

## `WorldStateRepository`
The simplest one — no caching, no persistence, a pass-through to
`ServiceProtocol.fetch(.worldState(platform:))`. `getWorldState(platform:)`
defaults to `.pc` via a protocol extension (the same default-argument-via-
extension trick every repository protocol in this app uses, since protocol
methods can't have default parameter values directly).

## `ProfileRepository`
```swift
func getProfile(withPlayerId: String?, forceRefresh: Bool) async throws -> Profile
```
Cache policy, inline in `getProfile`:
1. Fetch whatever's persisted (`ProfileDataModel`, at most one row).
2. If not `forceRefresh` and the stored profile's `lastUpdated` is *today*
   (`Calendar.current.isDateInToday`) and `syncPolicy == .daily`, return the
   cached value — no network call.
3. Otherwise resolve a `playerId` (the passed-in one, or fall back to the
   stored profile's own account ID — so `forceRefresh` can be called with no
   ID and still know who to refresh), fetch from the network, persist, return.
4. No `playerId` resolvable at all → `ProfileError.noPlayerId`.

`syncPolicy: SyncPolicy` (currently just `.daily`, defined in
`CatalogRepository.swift` and shared by both repositories) is a stored
property, not a global constant — set at init, not currently overridden
anywhere, but the seam exists for a "sync policy per repository instance"
feature if that's ever needed (e.g. a settings toggle for refresh frequency).

## `CatalogRepository`
The most complex repository — six protocol methods, because "the catalog"
is really three different shapes consumers need:
- **Full catalog** (`getMasteryCatalog`/`syncMasteryCatalog`) — every item,
  used by Openings (needs the full unmastered-item list to match against
  world state).
- **Summary** (`getMasterySummary`/`syncMasterySummary`) — per-category
  counts/points only, used by the Mastery tab's root screen.
- **Single category** (`getCatalogContainer(for:)`) / **single source
  category** (`getMasterySources(named:)`) — used by Mastery's detail
  screens, fetched lazily on push rather than upfront.

Every `sync*` variant follows the same shape: `ensureCatalogSeeded()` (loads
`masterycatalog.json` into SwiftData on first-ever call, no-ops after), then
delegates the actual profile-merge to `CatalogSyncService` inside a single
`persistencyService.perform` transaction (`mergeProfile` static helper) —
the repository owns *when* to sync, the service owns *how* to merge. This
split is deliberate: `CatalogSyncService` is a pure, stateless, easily-tested
function (see [Services](Services.md)); the repository is where the SwiftData
transaction, seeding, and cache-shape logic live.

The `sync*` vs. plain `get*` distinction exists because callers sometimes
have a fresh profile in hand already (Settings' explicit refresh) and
sometimes don't (a cold Mastery-tab load with no profile fetched yet) — the
`get*` variants just read what's persisted without attempting a merge.

## Conventions for adding a new repository
1. Protocol first, with a default-argument extension for anything that
   should have a convenience zero-arg call site.
2. `Default*Repository` or `Persistent*Repository` naming depending on
   whether it touches `PersistencyService` (`Persistent` prefix) or is a
   pure network pass-through (`Default` prefix) — see `DefaultWorldStateRepository`
   vs. `PersistentCatalogRepository`/`PersistentProfileRepository`.
2. Inject `ServiceProtocol`/`PersistencyService`/nested services via
   initializer with a real default (`APIManager()`, `DefaultCatalogSyncService()`)
   so call sites don't need to know about them — only `AppDependencies`
   overrides defaults, and only tests inject stubs.
3. Wire the concrete type into `AppDependencies`, never construct a
   repository inline in a View or ViewModel.

## Test coverage
`ProfileRepositoryTests` covers the cache/force-refresh branch logic in
detail. No `CatalogRepositoryTests` or `WorldStateRepositoryTests` — given
`CatalogRepository` is the most complex type in the app (six methods, a
seeding path, a merge transaction), this is the single biggest coverage gap
in the codebase.
