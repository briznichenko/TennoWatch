# Layer: Repositories

`TennoWatch/Repositories/` — the boundary every ViewModel talks to.
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

The profile repository resolves an explicit account ID or the persisted active account. A fresh remote profile uses the daily cache; `forceRefresh` fetches and explicitly updates the existing account row. A missing account creates a local profile with a persisted UUID, and local profiles bypass the network even when force refresh is requested.

`getSavedProfiles()` lists saved accounts, `selectProfile(accountID:)` selects a cached profile, `createLocalProfile()` restores or creates the manual profile, and `deleteProfile(accountID:)` removes one account's graph. The active account is exposed through `currentAccountID` and persisted by the injected `AccountIDStoring` instance.

Profile import builds or refreshes that account's mastery catalog before promoting the account to the active selection. A selection revision and account-ID check reject delayed requests after the selection changes. Cached selection and deletion are usable offline.

## `CatalogRepository`

Consumers request a full catalog, category summary, single item category, or non-item category. Every read resolves a profile-owned graph, rebuilds it when the bundled catalog changes, and recalculates remote mastery from that profile's persisted records inside one `perform(_:)` operation.

Plain `get*` methods use the active account. `sync*` methods use the supplied profile's account ID and read its latest persisted records; they do not change the active account or merge one account's snapshot into another account's graph.

Static item definitions are shared by unique name. Mastery rows, source completion, and summary counters belong to individual profiles. See [Persistency](Persistency.md) for ownership, legacy-store repair, and the actor boundary.

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

`ProfileRepositoryTests` covers cache and force-refresh behavior. `ProfileIsolationTests` exercises real SwiftData storage for multi-profile overlap, replacement refreshes, consistent category totals, local profile identity, deletion, legacy graph repair, and delayed requests. `MasteryItemPersistenceTests` covers AX-52 and reads from a new model context. `WorldStateRepository` still has no direct repository tests.
