# Layer: Services

`TennoWatch/Services/` contains pure domain transformations, shared presentation
state, and local notification delivery/scheduling. These have different isolation
requirements; not every service is stateless.

## Catalog synchronization

`CatalogSyncService: Sendable` exposes two `mergeProfile` overloads:

- **Items** — maps each catalog item to the profile item with the same unique
  name. Missing matches become `nil`, clearing previous progress. Duplicate profile
  types retain the first match in this service; profile persistence normalizes
  duplicates by highest XP before repository synchronization.
- **Non-item sources** — recreates completion from the supplied profile. Steel Path
  sources require the base mission's tier to equal `StarChartRules.steelPathTier`;
  ordinary missions require `completes > 0`; intrinsics require at least
  `MasteryRules.maximumIntrinsicRank` (10). Unmatched sources become incomplete.

`DefaultCatalogSyncService.makeCatalogs(from:)` groups items by category for
initial catalog seeding. Repository graph synchronization also updates persisted
item links and counters; see [Repositories](Repositories.md).

## Openings matching

`OpeningsMatchingService: Sendable` maps unmastered items and a world-state
snapshot into `[TimeSensitiveOpening]`. It checks both factions' rewards in
non-completed invasions, Void Trader stock, and Vault Trader stock.

Matching tries, in order:

1. Exact `uniqueName`, when supplied.
2. A trimmed, case-insensitive exact display name.
3. A case-insensitive display name plus a recognized component suffix, such as
   ` Blueprint`, ` Barrel`, or ` Systems`.

It does not use arbitrary substring matching. Component rewards identify the
parent mastery item; the result does not establish that all crafting parts are
available. Unknown suffixes and localized reward names can remain unmatched.

Reward matches are deduplicated by item unique name. Across all matching passes,
results are grouped by item ID, their distinct sources are combined in order,
and results are sorted by ID. Multiple invasions or traders can therefore appear
on the same opening rather than discarding every source after the first.

## Error presentation

`ErrorManager` and `DefaultErrorManager` are explicitly `@MainActor`;
`DefaultErrorManager` is `@Observable`. This is shared mutable presentation state.
`append(_:)` ignores cancellation and retains original errors, with debug printing.
`currentError` reads the last queued error, and `finishPresentation()` pops it:
the queue presents the most recently appended error first.

The alert bridge maps errors into user-facing messages through `AppErrors`.
App startup retains a database failure and displays recovery guidance instead of
silently replacing the persistent store. See `AppErrorsTests` for these paths.

## Local notifications

`NotificationService: Sendable` abstracts authorization, scheduling a
`ScheduledNotification`, and cancellation. `DefaultNotificationService` bridges
to `UNUserNotificationCenter` and handles foreground notification presentation.

`DefaultVoidTraderNotificationScheduler` is an actor implementing the Sendable
`VoidTraderNotificationScheduler` contract. It schedules a fixed-ID arrival reminder
when the preference is enabled and the supplied trader activation is in the future.
World State fetches and the Settings toggle trigger synchronization. Disabling the
preference or clearing app data cancels the reminder. There is no background world-state
polling or APNs integration, so scheduling depends on data obtained while using the app.

## Conventions and coverage

Use a narrow protocol and inject dependencies through the owning repository or
ViewModel. Keep pure transformations in Sendable structs; explicitly isolate
mutable UI state and actor-owned scheduling state.

`CatalogSyncServiceTests` and `OpeningsMatchingServiceTests` cover domain matching.
`AppErrorsTests` covers error mapping, queue/cancellation behavior, startup, and wiki
errors. Notification delivery and scheduling have no dedicated test suites.
