# Tab: Openings

## Purpose
The cross-cutting tab: takes "what I still need for mastery" (Mastery tab's
domain) and "what's happening right now" (World State tab's domain) and
answers "what should I go do today." It's the tab that justifies having both
of the others — nothing here is fetched independently, it's a matching pass
over data the other two tabs already own.

## Entry point
`MainView` → `Tab("Openings")` → [`OpeningsView`](../../WarframeListener/Views/Openings/OpeningsView.swift),
constructed with `profileRepository`, `catalogRepository`, `worldStateRepository`,
`errorManager` — the only tab that depends on all three repositories.

## Screens
1. **`OpeningsView`** — thin root, delegates straight to `OpeningsListView`.
2. **`OpeningsListView`** — two sections:
   - **Time-sensitive** — `TimeSensitiveOpeningRowView` per match (an
     invasion carrying the item as reward, or the Void Trader stocking it).
     Empty state text when nothing matches right now.
   - **Permanent** — everything else still unmastered, grouped by category
     (items) or source-category name (non-item sources), same
     `OpeningsCategoryRowView` count-row pattern for both, pushing to
     `OpeningsItemCategoryDetailView` / `OpeningsSourceCategoryDetailView`.
     Both sub-lists are unfiltered — no filter/sort pills like Mastery's
     detail screens, since this is already a filtered ("still needed") view.

## ViewModel — `OpeningsViewModel`
- Fetches catalog and world state **concurrently** via `async let` — the one
  place in the app using structured concurrency for parallel fetches instead
  of sequential `await`s:
  ```swift
  async let fetchedCatalog = fetchCatalog()
  async let fetchedWorldState = fetchWorldState()
  catalog = await fetchedCatalog
  worldState = await fetchedWorldState
  ```
  Each sub-fetch catches its own errors and pushes to `errorManager`
  independently, so a world-state failure doesn't block catalog data from
  showing (and vice versa) — a real user-facing benefit, not just a
  concurrency exercise, since this tab's two data sources are genuinely
  independent and either failing shouldn't blank the other's section.
- `unmasteredItems` — all obtainable, unmastered `MasteryItem`s, computed
  fresh from `catalog` every access (not cached).
- `matchedOpenings` — runs `OpeningsMatchingService.timeSensitiveOpenings(for:in:)`
  over `unmasteredItems` + `worldState`. The matching logic itself
  (name-matching against invasion rewards / Void Trader inventory) lives in
  the service, not here — see [Services](../Layers/Services.md).
- `permanentMasteryItems` — `unmasteredItems` minus whatever
  `matchedOpenings` already claimed (by `catalogItemModel.uniqueName`), so an
  item never appears in both sections.
- `permanentSourceGroups` — non-item sources, grouped by source-category
  name, dropping categories with nothing left unmastered.
- Two lazy lookup functions, `permanentItems(in:)` / `permanentSources(in:)`,
  used only when a detail screen is pushed — avoids building every category's
  full item list up front.

## Model — `TimeSensitiveOpening`
Plain value type, not persisted: `item: MasteryItem` + `Source` (`.invasion`
or `.voidTrader`, each carrying just enough context to render — node/faction/
completion, or location/expiry). `id` is the item's `uniqueName`, so a given
item can only produce one opening even if it matches multiple invasions
(first match wins, since matching is dictionary-keyed by unique name in the
service — see Services spec).

## Known gaps / TODOs
- Matching is name-based fallback (`localizedCaseInsensitiveContains`) when
  there's no exact `uniqueName` hit — see the Services spec for the
  false-positive risk this carries with short/generic item names.
- No sortie/Nightwave/relic-fissure matching — only invasions and the Void
  Trader feed into "time-sensitive." Fissures dropping a needed relic, or a
  Nightwave challenge rewarding an item, wouldn't surface here even though
  they're just as time-boxed.
- `.refreshable` calls `fetchOpenings()` unconditionally (no force-refresh
  flag threaded through, unlike Profile/Settings) — every pull-to-refresh
  re-syncs the profile against the catalog, which is the correct behavior
  here but worth noting it's not consistent with the `forceRefresh` pattern
  used elsewhere.

## Test coverage
`OpeningsMatchingServiceTests` covers the matching logic. No
`OpeningsViewModelTests` — the grouping/dedup logic in the ViewModel itself
(`permanentMasteryItems`, `permanentSourceGroups`) is untested.
