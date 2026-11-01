# Layer: Testing

`TennoWatchTests/` uses Swift Testing (`import Testing`, `@Suite`, `@Test`) with
fixtures, injected protocol implementations, and in-memory SwiftData stores.

## Existing coverage

- **`APIManagerTests`** — response/date decoding, HTTP/transport retry policy,
  Retry-After, cancellation, TTL expiry, cache keys, profile bypass, and invalidation.
- **`ProfileRepositoryTests`** — profile cache and force-refresh behavior.
- **`ProfileIsolationTests`** — real persistence and repositories: overlapping
  accounts, replacement progress, local identity, deletion, legacy repair, delayed
  selection safety, synchronized-graph reuse, and catalog invalidation/rebuilding.
- **`MasteryItemPersistenceTests`** — AX-52 mastery after syncing the bundled
  profile, and mastered state surviving reads from another model context.
- **`CacheClearingTests`** — deletion of persisted profiles and related catalog data.
- **`CatalogSyncServiceTests`** — item and non-item mastery merge rules.
- **`OpeningsMatchingServiceTests`** — reward/trader matching and source aggregation.
- **`AppErrorsTests`** — user-facing error mapping, cancellation suppression,
  error-queue behavior, startup success/failure, and wiki error handling.
- **`WorldStateViewModelTests`** — success/failure/cancellation, loading lifecycle,
  cycle mapping, and invasion/fissure sorting.

## Coverage boundaries

Catalog repository behavior has integration coverage through the persistence
suites, but no dedicated `CatalogRepositoryTests` suite. `WorldStateRepository`
has no direct repository tests. World State is the only feature ViewModel with
its own suite; Mastery, Openings, Profile, Settings, and Wiki ViewModels do not
have dedicated suites. The mastery-rank threshold calculation and the item XP
formula lack focused boundary tests. Local notification scheduling and SwiftUI
views have no dedicated suites; there is no UI/snapshot test target.

## Patterns to reuse

- Stub the narrowest real dependency protocol, without a mock framework.
- `ControlledWorldStateRepository` uses `withCheckedThrowingContinuation` to
  suspend a fetch until the test resumes it, making loading-state assertions
  deterministic. Every continuation must be resumed exactly once; avoid tests
  that leave suspended requests unresolved.
- Reuse static model factories in `Support/Fixtures.swift`, overriding only the
  fields relevant to a test.
- Use an in-memory `ModelContainer` when SwiftData behavior is part of the test.
  Keep model access inside the owning context/actor and compare value snapshots.

## Workflow and new coverage

Use the shared `TennoWatch` scheme on macOS and an iOS simulator after relevant
changes. [CI documentation](../../.github/README.md#local-validation) contains the
local build/test commands and destination overrides.

Discuss new test scope before adding coverage, per [AGENTS.md](../../AGENTS.md).
Mirror the source area under `TennoWatchTests`, use `@testable import TennoWatch`,
and prefer deterministic fixtures over live API calls.
