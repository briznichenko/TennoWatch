# Tab: Mastery

## Purpose and entry point

Mastery derives progress by matching a profile against the bundled catalog.
`MainView` builds `MasteryViewModel` from profile/catalog repository protocols and
the shared error manager, then passes it into `MasteryView`.

## Screens and navigation

`MasteryView` owns a `MasteryCoordinator` and binds its `NavigationPath` to the
navigation stack. Typed destinations resolve category details, non-item source
details, and the mastery breakdown. The parent ViewModel creates detail ViewModels.
Changing the selected account recreates the tab and its navigation state.

- The root shows a rank summary card, an expandable adaptive item-category grid,
  and non-item source cards. Tapping the rank card opens `MasteryBreakdownView`.
- `MasteryCategoryDetailView` and `MasterySourceCategoryDetailView` load once and
  provide search, missing/mastered/locked filter pills, and name/points-remaining
  sorting. They share filter and sort types through aliases.
- `MasteryItemView` is an item row backed by `MasteryItemViewModel`, with mastery
  state, rank/remaining-points presentation, and shared wiki access.

## ViewModel and rank progress

`MasteryViewModel` loads `MasteryCatalogSummary` for the root rather than every item.
The breakdown loads the full catalog on demand. Earned XP includes both item
and non-item categories. Settings can exclude locked (unobtainable) items from
category completion counts and breakdown remaining XP. This preference updates
live, preserves earned XP and rank progress, and leaves the Locked filter available.

The current rank helper uses cumulative `2500 * rank * rank` through rank 30
(2,250,000 XP), then adds 147,500 XP per Legendary rank. Remote profiles use their
reported player level as the displayed rank; local profiles derive completed ranks
from XP. Rank progress and the item XP-to-rank formula are separate calculations.
These values describe the implementation; changes to the game rules require a
separate source check.

## Loading and refresh

`fetchCatalog(forceRefresh:)` first obtains the active profile, then reads
`catalogRepository.getMasterySummary()`. Only `ProfileError.noPlayerId` is handled
as an absent profile; other failures go to `ErrorManager`. The ViewModel checks
cancellation before publishing the new summary and suppresses cancellation errors.
It does not silently fall back on every profile-fetch failure.

The root task and manual refresh currently call `fetchCatalog()` without forcing
profile refresh, so the repository's daily profile cache still applies. Profile
sync and Settings refresh provide force-refresh paths. Category-detail screens
have no separate refresh control. See [Repositories](../Layers/Repositories.md)
for conditional catalog synchronization and profile isolation.

## Coverage and limitations

There are no dedicated Mastery ViewModel suites or focused threshold tests for
rank progress. `CatalogSyncServiceTests` covers merge rules; persistence/isolation
suites cover item progress and profile-owned catalogs. Manual profile item editing
is not implemented.
