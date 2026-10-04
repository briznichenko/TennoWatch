# Layer: Persistency

`TennoWatch/Persistency/` contains SwiftData models and the generic persistence service. Repositories own domain mutations through `PersistencyService.perform(_:)`; views receive `Sendable` value snapshots.

## Ownership and identity

- `ProfileDataModel.accountID` uniquely identifies a saved remote profile or a local manual profile. Local profiles set `isLocal` and persist a UUID in `accountID`; the UUID is never sent to the profile endpoint.
- A profile owns its items, missions, intrinsic skills, account statistics, and one mastery catalog. Deleting the profile cascades through these records.
- Each mastery catalog owns its category containers and non-item categories. Containers own mastery rows; non-item categories own their source rows.
- `CatalogItemDataModel.uniqueName` identifies a shared static item definition. Deleting a profile preserves these definitions.
- Profile item types, mission tags, intrinsic names, display names, source names, and catalog schema versions are not globally unique. These values overlap between profiles.
- A mastery row references the corresponding item owned by its profile. The mastery row does not own or cascade-delete that profile item.

## Reading and refreshing

`PersistentProfileRepository` explicitly updates the existing account row when refreshing. It replaces the profile's item/mission/skill arrays, updates account statistics in place, and normalizes repeated item types by keeping the highest XP.

`PersistentCatalogRepository` resolves the requested or active profile, prepares that profile's catalog, attaches its profile items, and recalculates category counters before returning a snapshot. Summary, category detail, non-item sources, and Openings read the same profile-owned graph. Category enum comparisons happen in memory after resolving the catalog; they are not SwiftData predicates.

A remote refresh replaces previous progress, including clearing absent item links and source completion. It does not increment counters or preserve another profile's mastery. Local profiles are initialized with empty progress and bypass remote synchronization. Manual item-editing controls are future work.

## Actor boundary

`DefaultPersistencyService` is a `@ModelActor`. `perform(_:)` executes a synchronous closure against its context, so a complete graph mutation and snapshot conversion finish without suspension inside that operation. Repository operations save before returning and roll back failed mutations. Models remain inside the context; only value snapshots cross the actor boundary.

Repository methods still suspend while awaiting networking or actor operations. Profile selection uses a revision counter and account-ID checks so a delayed request cannot overwrite a newer selection. SwiftUI recreates Mastery and Openings when the active account changes, discarding their previous snapshots and navigation stacks.

## Existing stores and catalog updates

New persisted fields use defaults or optional relationships. SwiftData migrates the old schema without resetting the database. A legacy catalog has no owning profile; its derived graph is deleted per object and rebuilt from the selected profile. Remote profiles are marked stale during this repair so subsequent profile loading refreshes potentially incomplete legacy cache data.

Catalog graphs are rebuilt per profile when either the bundled schema version or generation timestamp changes. Remote mastery is reconstructed from cached profile data. Catalog reseeding does not delete profile-owned statistics.

`clearAllData()` retains the complete app reset behavior: it deletes all persisted model types through fetched-object deletion, then saves.

## Verification

`ProfileIsolationTests` covers overlapping profiles, consistent item/summary totals, replacement refreshes, manual UUID identity, cascading deletion, legacy graph repair, and delayed profile requests. `MasteryItemPersistenceTests` checks AX-52 against the bundled profile and snapshot reads from another context. Cache-clearing and profile-repository suites cover the existing reset and cache behavior.
