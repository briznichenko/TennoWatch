# Layer: Services

`TennoWatch/Services/` — stateless business logic that's too specific
to belong in a Model but too domain-focused to belong in a Repository. All
three services here are protocol + pure-function-ish struct implementation,
easy to unit test in isolation (and, in two of three cases, already are).

## `CatalogSyncService`
```swift
protocol CatalogSyncService: Sendable {
    func mergeProfile(_ profile: Profile, into items: [MasteryItem]) -> [MasteryItem]
    func mergeProfile(_ profile: Profile, into sources: [MasterySourceModel]) -> [MasterySourceModel]
}
```
The core mastery-tracking logic, two overloads for the two "obtainable
thing" shapes (items vs. non-item sources like intrinsics/junctions):
- **Items**: builds a `[uniqueName: ProfileItemModel]` dictionary from the
  profile's owned items, then maps each catalog item to a new `MasteryItem`
  carrying the matched `profileItemModel` (or whatever it already had, if no
  match — so re-merging never *loses* progress, only adds it).
- **Non-item sources**: three different "is this mastered" rules depending
  on what kind of source it is —
  - **Steel Path** variant (`uniqueName` suffixed `#steelPath`): mastered if
    the equivalent non-Steel-Path mission tag has a `tier` value at all.
  - **Mission-tagged** source: mastered if `completes > 0`.
  - **Intrinsic**: mastered if `playerSkills[uniqueName] >= 10` (max
    intrinsic rank, hardcoded — Warframe's actual cap).
  This is the single piece of domain knowledge in the app most likely to go
  stale if Digital Extremes changes how Steel Path or intrinsics work —
  worth flagging in a PR description if you ever touch it, since there's no
  way to detect staleness other than a player noticing wrong mastery state.
- `static func makeCatalogs(from:)` — groups a flat `[MasteryItem]` into
  `[CatalogContainer]` by category, used only during initial catalog
  seeding (`MasteryCatalogDataModel.init(from:)`), not part of the sync path.

## `OpeningsMatchingService`
```swift
protocol OpeningsMatchingService {
    func timeSensitiveOpenings(for items: [MasteryItem], in worldState: WorldState) -> [TimeSensitiveOpening]
}
```
Two independent matching passes, concatenated:
- **Invasions**: for every non-completed invasion, both factions' rewards
  (if any), matched against the unmastered item list.
- **Void Trader**: every inventory item, matched the same way.

Matching itself (`matchingItems(uniqueName:displayName:in:)`) tries an exact
`uniqueName` match first, and **only if that fails**, falls back to
`localizedCaseInsensitiveContains` on display name. This fallback exists
because reward payloads don't always carry a clean `uniqueName` (some are
just display strings), but it's a real false-positive risk: a short or
generic item name (e.g. anything that's a substring of another item's name)
could match the wrong catalog entry. `OpeningsMatchingServiceTests` is the
place to check before trusting this at the edges.

Dedup: `matchingItems(in reward:from:)` collects results into a
`[uniqueName: MasteryItem]` dictionary before returning, so one reward
listing the same item under two different display strings doesn't produce
duplicate openings — but this also means if a name-fallback match is wrong,
it silently overwrites rather than surfacing as a conflict.

## `ErrorService`
```swift
@Observable @MainActor
final class DefaultErrorManager: ErrorManager {
    var errorQueue: [Error]
    var currentError: Error?  // errorQueue.last
    func append(_:) / beginPresentation() / finishPresentation()
}
```
Not stateless like the other two — this is the one service that's really a
piece of shared UI state, injected everywhere (every top-level ViewModel
holds an `errorManager: ErrorManager` and every top-level View attaches
`.handleErrorAlert(with:)`). A FIFO-ish queue (`append` pushes, `currentError`
reads the *last* pushed error, `finishPresentation` pops it) — so if two
errors land back-to-back, the most recent one is shown first and the older
one surfaces after it's dismissed, not the other way around. `#if DEBUG`
also `print`s every appended error, which is the only logging in the app.

## Conventions for adding a new service
Protocol with a single clear responsibility, `Sendable` if it'll be called
from concurrent contexts (persistency transactions do this — see
`CatalogSyncService`), `Default*` struct implementation with no stored
mutable state unless the service genuinely needs to be observable UI state
like `ErrorManager`. Inject via the owning repository/ViewModel's initializer
with a real default, same as repositories.

## Test coverage
`CatalogSyncServiceTests` and `OpeningsMatchingServiceTests` both exist and
cover the interesting branches (Steel Path, intrinsic threshold, exact vs.
fallback name matching). `ErrorService` is untested, but it's simple enough
(a queue push/pop) that the risk is low.
