# Tab: World State

## Purpose
Live snapshot of the game's shared world state — the "what's happening right
now" board. First tab, and the simplest vertical slice in the app: no
persistence, no profile dependency, single repository.

## Entry point
`MainView` → `Tab("World state")` → [`WorldStateView`](../../WarframeListener/Views/WorldState/WorldStateView.swift),
constructed with `worldStateRepository` and `errorManager` from `AppDependencies`.

## Screens
- **`WorldStateView`** — root. Wraps `WorldStateListView` in a `NavigationStack`,
  owns the `.task`/`.refreshable` fetch lifecycle and the loading overlay
  (shown only while `worldState == nil`, so pull-to-refresh doesn't blank the
  screen).
- **`WorldStateListView`** — the actual `List`, seven independently-hidden
  sections in this order: Void Trader, Nightwave, invasions (summary +
  drill-down), cycles, fissures (summary + drill-down), sortie, Archon Hunt.
  Every section is `@ViewBuilder`-gated on its data being present (e.g. no
  Void Trader row when he's not around) — nothing renders an empty state.
- **`InvasionListView`** / **`FissureListView`** — pushed detail lists,
  reached by tapping the summary rows (`InvasionsSummaryRowView`,
  `FissuresSummaryRowView`). Grouped by planet / by relic tier respectively
  (`viewModel.invasionsByPlanet` / `.fissuresByTier`).
- **`NightwaveListView`** — pushed from `NightwaveRowView`, lists challenges
  via `NightwaveChallengeRowView`.
- **`InvasionView`** — per-invasion detail (attacker/defender factions,
  rewards, completion).
- Sortie and Archon Hunt reuse the same `SortieRowView` for both — Archon
  Hunt is modeled as a sortie variant, not a separate type.
- Remaining row views: `CycleRowView`, `FissureRowView`, `VoidTraderRowView`.

## ViewModel — `WorldStateViewModel`
- State: `worldState: WorldState?`, `isLoading: Bool`.
- `fetchWorldState()` — the only mutating entry point. Always a full refresh;
  no force/normal distinction (unlike Profile/Mastery) since there's nothing
  to cache against.
- Derives four view-facing shapes from the raw model, none of which exist on
  `WorldState` itself:
  - `cycles: [WorldCycleDisplay]` — flattens the five open-world cycles
    (Cetus, Vallis, Cambion, Zariman, Earth) into one displayable list, each
    with a manually-picked title/state string pair (day/night, warm/cold,
    Corpus/Grineer, or the raw Cambion state capitalized).
  - `invasions: [Invasion]` — sorted by node.
  - `fissures: [Fissure]` — sorted by soonest expiry (`.distantFuture` for
    fissures with no expiry, so they sort last).
  - `invasionsByPlanet` / `fissuresByTier` — grouped + sorted, the latter
    against a hardcoded tier order (`Lith, Meso, Neo, Axi, Requiem, Omnia`)
    rather than alphabetical, since that's the game's actual difficulty order.

## Data dependency
Only `WorldStateRepository.getWorldState(platform:)`, defaulted to `.pc` via
a protocol extension. No platform picker in the UI yet — every call uses PC
data. Cross-platform support would mean threading a platform selection down
from Settings or a per-tab picker; not built.

## Known gaps / TODOs
- No platform selector — hardcoded to `.pc`.
- No local caching of world state (every tab visit refetches); this is
  probably correct given the data is live and short-lived, but worth a
  conscious call if a "last known state while offline" feature ever comes up.
- Sortie, Archon Hunt, Nightwave, and Void Trader are read straight off
  `viewModel.worldState?.x` in the view rather than through a ViewModel
  computed property — inconsistent with cycles/invasions/fissures, which get
  dedicated `WorldCycleDisplay`/grouping types. Fine today since none of them
  need derived display logic yet; would need to follow the existing pattern
  (computed property on the ViewModel, not raw model access from the view) if
  that changes.

## Test coverage
[`WorldStateViewModelTests`](../../WarframeListenerTests/ViewModels/WorldStateViewModelTests.swift)
— the only ViewModel under test in the whole app. Covers the fetch/error path
and (presumably, given the file exists) the grouping/sorting logic. No view
tests (expected — this is a SwiftUI app, no snapshot/UI test target yet).
