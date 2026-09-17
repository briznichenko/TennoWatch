# Tab: Mastery

## Purpose
Tracks mastery-rank progress against a locally-generated item catalog,
merged live against the player's profile. This is the tab with the most
layers below it — persistence, a generated catalog seed, and a merge/sync
service — because "mastery" isn't in the profile API response as a single
number; it's derived by cross-referencing owned items and their ranks.

## Entry point
`MainView` → `Tab("Mastery")` → [`MasteryView`](../../TennoWatch/Views/Mastery/MasteryView.swift),
constructed with `profileRepository`, `catalogRepository`, `errorManager`.

## Screens (three-level drill-down)
1. **`MasteryView`** — root. Rank badge + XP progress bar (`Surface` +
   `ProgressBar`), then a `categoryList` section (one row per item category:
   warframes, primaries, melee, etc.) and an `otherSourcesList` — one
   `Section` per non-item source category (intrinsics, junctions, etc.),
   since those aren't grouped under a single umbrella the way items are.
2. **`MasteryCategoryDetailView`** / **`MasterySourceCategoryDetailView`** —
   pushed per-category list. Both share the same `Filter`
   (missing/mastered/locked) and `SortOption` (name/points-remaining) enums —
   literally the same type, aliased via `typealias` in the source-category
   variant (`MasterySourceCategoryDetailViewModel.Filter = MasteryCategoryDetailViewModel.Filter`)
   rather than duplicated. Filter UI is `FilterPills` pinned in a
   `safeAreaInset(edge: .top)`; sort is a toolbar `Menu` with a `Picker`.
   Loads once (`guard container == nil else { return }` / `guard category == nil`)
   — no pull-to-refresh at this level, the parent tab's refresh is the only
   way to force a resync.
3. **`MasteryItemView`** — leaf row, not a pushed screen. Renders an
   `MasteryItemViewModel` (icon by state, dimmed when mastered/locked,
   rank/points-remaining text).

## ViewModels
- **`MasteryViewModel`** — root. `summary: MasteryCatalogSummary?` (a
  lightweight, per-category rollup — counts and points only, not the full
  item list) rather than the full `MasteryCatalog`, so the root screen loads
  fast. `earnedMasteryXP` sums points across item categories *and* non-item
  categories. `rankProgress` runs the game's actual MR curve
  (`2500 * rank * (rank + 1)`, hardcoded — this is Warframe's real formula,
  not a guess) via a static helper, not delegated to a model or service.
  That quadratic curve only holds through rank 30 (the cap, 2,325,000 XP);
  every "Legendary" rank past 30 costs a flat 162,000 XP instead, which the
  helper branches on separately.
  Exposes `makeCategoryDetailViewModel(for:)` / `makeSourceDetailViewModel(for:)`
  factories for the two detail-screen types.
- **`MasteryCategoryDetailViewModel`** — loads the *full* `CatalogContainer`
  for one category (all items, not just the summary) on first appearance.
  Owns `Filter`/`SortOption` as nested enums; `Filter.matches(_:)` maps to
  `MasteryItem.MasteryState` (`.unmastered`/`.partiallyMastered` both count
  as "missing").
- **`MasterySourceCategoryDetailViewModel`** — same shape, one category of
  `MasterySourceModel` (non-item sources) instead of `MasteryItem`.
- **`MasteryItemViewModel`** — pure presentation wrapper around one
  `MasteryItem`; no repository, no loading state, just computed display
  strings/icons keyed off `MasteryState`.

## Data dependency & sync flow
`fetchCatalog(forceRefresh:)`:
```
if let profile = try? await profileRepository.getProfile(forceRefresh:) {
    summary = try await catalogRepository.syncMasterySummary(with: profile)
} else {
    summary = try await catalogRepository.getMasterySummary()
}
```
Profile fetch failure is swallowed (`try?`) and falls back to whatever's
already persisted — mastery data degrades gracefully to "stale but present"
rather than erroring out when the profile API is unreachable. The actual
merge logic (owned-item lookup, intrinsic-rank thresholds, Steel Path suffix
handling) lives one layer down in [`CatalogSyncService`](../Layers/Services.md);
this ViewModel doesn't know the merge rules.

## Known gaps / TODOs
- No forced-refresh affordance visible at the category-detail level; if the
  profile changes mid-session (e.g. you master something while the app is
  open) you'd need to pull-to-refresh the root tab, not the detail screen.
- `MasteryViewModel`'s hardcoded MR-curve formula has no test asserting it
  against known in-game rank thresholds (see [Testing](../Layers/Testing.md))
  — worth a couple of `#expect` cases pinning rank 1↔2 and a higher rank.

## Test coverage
No dedicated `MasteryViewModelTests` yet. `CatalogSyncServiceTests` covers
the merge logic one layer down; the ViewModel's own derived properties
(`rankProgress`, `earnedMasteryXP`) are untested.
