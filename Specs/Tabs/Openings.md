# Tab: Openings

## Purpose and entry point

Openings combines unmastered catalog items with current world state to suggest
acquisition opportunities. It fetches through shared repositories rather than
reading the other tabs' ViewModels.

`MainView` constructs `OpeningsViewModel` with profile/catalog/world-state
repositories and the shared error manager. The matching service is injectable.

## Screens

`OpeningsView` owns the navigation stack and fetch lifecycle; `OpeningsListView`
shows summary counts, time-sensitive matches, and an initially collapsed permanent
section. Search filters item names/unique names and non-item source text.

Time-sensitive rows display the item's matching invasion and trader sources.
Permanent categories contain obtainable, unmastered items not claimed by a current
match, plus positive-mastery non-item sources that are not complete. Category links
open searchable `OpeningsItemCategoryDetailView` or
`OpeningsSourceCategoryDetailView`, seeded with the current search text. These
screens do not use Mastery's mastery-state filter pills.

## Concurrent loading and refresh

`fetchOpenings(forceRefresh:)` uses `async let` to load catalog and world state
concurrently. Catalog loading obtains the profile with normal cache policy and
then reads its catalog. Each child catches failures independently and returns
`nil`, allowing the other section's data to load. Results are assigned after both
children finish, with a cancellation check before publishing them.

The root task uses normal loading. Manual refresh passes `forceRefresh: true`,
clearing the world-state network cache; it does not force a remote profile refresh.
Structured child tasks belong to the parent task's lifetime, but cancellation
still requires cooperative handling at suspension points and before state updates.

## Matching and model

`TimeSensitiveOpening` contains an item and an array of sources: invasion,
Void Trader, or Vault Trader. Its ID is the item's unique name. The service groups
matches into one opening per item and combines distinct sources, so multiple
invasions or traders can be retained on one row.

Matching uses exact unique names, case-insensitive display names, then recognized
component suffixes. See [Services](../Layers/Services.md) for the matching order
and limitations. It does not use arbitrary substring matching.

## Limitations and coverage

There is no sortie/Nightwave/relic-fissure matching. The permanent section is the
remaining catalog, not proof that each item is obtainable immediately. Component
rewards do not establish that all crafting ingredients are available.

`OpeningsMatchingServiceTests` covers the service. There are no dedicated Openings
ViewModel suites for concurrent loading, search/grouping, or permanent exclusions.
