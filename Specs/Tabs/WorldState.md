# Tab: World State

## Purpose and entry point

The first tab displays the shared PC world-state snapshot. It has no profile
or SwiftData dependency. `MainView` constructs `WorldStateViewModel` with
`WorldStateRepository`, `VoidTraderNotificationScheduler`, and `ErrorManager`,
then passes it to [`WorldStateView`](../../TennoWatch/Views/WorldState/WorldStateView.swift).

## Dashboard and navigation

`WorldStateView` wraps `WorldStateGridView` in a `NavigationStack`. The dashboard
uses a scroll view with a wide Void Trader card, active events, and an adaptive
card grid. Accessibility text sizes use a single column. Cards appear only when
their corresponding data is available.

The grid covers invasions, fissures, sortie, Archon Hunt, Nightwave, Vault Trader,
Steel Path offerings, alerts, Archimedea, the calendar, flash sales, cycles, and
potential Prime releases. Inline `NavigationLink` destinations open their detail
lists/screens. Sortie and Archon Hunt share `SortieDetailView`; both traders share
`TraderInventoryListView`.

Invasions group by planet. Fissures group by star chart, then relic tier; the tier
order is Lith, Meso, Neo, Axi, Requiem, Omnia, with unknown tiers sorted afterward.
Cycles open `CycleListView`. Item/wiki actions use the shared `WikiCoordinator`.

## Fetch lifecycle and derived data

`fetchWorldState(forceRefresh: Bool = false)` loads through the repository and
then synchronizes the local Void Trader arrival reminder. Initial loading shows an
overlay only when no snapshot is present. Manual refresh passes `forceRefresh: true`
and clears the network cache first. Errors go to `ErrorManager`; cancellation is silent.

The repository delegates to `APIManager`, whose world-state cache has a 30-second
in-memory TTL. There is no persisted offline world-state snapshot or background
polling. See [Networking](../Layers/Networking.md) for retries and cache policy.

The ViewModel derives cycle displays, sorted invasions/fissures/alerts, grouped
navigation data, active events, and a bounded flash-sale preview. Active events
filter by activation/expiry and are reevaluated by a minute-based `TimelineView`.
Countdown components update locally; they do not fetch new world state.

## Potential Prime releases

The final grid card opens `PrimeReleaseListView`, listing up to six oldest released
base Warframes without a released Prime variant. The list labels the order as a
prediction; it does not invent release dates or enforce gender rotation. Umbra
and non-Warframe entries are excluded from the source snapshot.

`PrimeReleaseOrder` reads `Resources/primeReleaseOrder.json` independently of the
network and profile. The detail list displays the snapshot's update date. Refresh
it together with the mastery catalog through the
[game-data refresh workflow](../../.github/README.md#local-validation). For a standalone
update, download WFCD's `Warframes.json` and run
`python3 Scripts/generate_prime_release_order.py /path/to/Warframes.json`.

## Known limitations and tests

World-state requests default to `.pc`; there is no platform picker. A snapshot
can become stale while the app remains open, and countdown expiry does not itself
refresh inventory or remove expired API entries.

`WorldStateViewModelTests` covers fetch success/failure/cancellation, loading state,
cycle mapping, and invasion/fissure sorting. The newer dashboard derivations and
notification integration have no dedicated coverage. There are no UI/snapshot tests.
