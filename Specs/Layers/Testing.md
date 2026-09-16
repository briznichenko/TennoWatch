# Layer: Testing

`TennoWatchTests/` — Swift Testing (`import Testing`, `@Suite`/`@Test`),
not XCTest. Mirrors the source tree: `Networking/`, `Repositories/`,
`Services/`, `ViewModels/`, plus a shared `Support/Fixtures.swift`.

## What's covered
| Area | File | Notes |
|---|---|---|
| Networking | `APIManagerTests.swift` | fetch/decode path, likely the date-sentinel edge case |
| Repositories | `ProfileRepositoryTests.swift` | cache/force-refresh branch logic |
| Services | `CatalogSyncServiceTests.swift` | Steel Path / intrinsic / mission mastery rules |
| Services | `OpeningsMatchingServiceTests.swift` | exact vs. name-fallback matching |
| ViewModels | `WorldStateViewModelTests.swift` | the only ViewModel under test |

## What's not covered
`CatalogRepository` (the most complex type in the app — six methods, a
seeding path, a merge transaction), `WorldStateRepository`,
`MasteryViewModel`/`MasteryCategoryDetailViewModel`/`MasterySourceCategoryDetailViewModel`,
`OpeningsViewModel`, `ProfileViewModel`, `SettingsViewModel`,
`MasteryItem.rank`'s XP formula directly, `ErrorService`. See each tab/layer
spec's own "Known gaps" section for specifics — this is the rollup.

## Patterns worth reusing (established in `WorldStateViewModelTests.swift`)
- **Stub repositories conform to the real protocol**, not a mock framework —
  `StubWorldStateRepository` holds a `Result<WorldState, Error>` and returns/throws
  it from the protocol method. This is the pattern any new
  `ViewModelTests` file should follow: a private `Stub*Repository` per test
  file, not a shared generic mock.
- **`ControlledWorldStateRepository`** — a second stub that uses
  `withCheckedThrowingContinuation` to let a test deterministically control
  *when* an in-flight request resolves (`waitForRequestToStart()` /
  `resume(with:)`), specifically to test `isLoading` transitions without a
  race. This is the one place in the codebase demonstrating the
  continuation-bridging pattern from the project's Swift 6 learning goals —
  worth a close read if `withCheckedThrowingContinuation` is still building
  intuition, since it shows both the "give the test a checkpoint" and
  "resume it under test control" halves of the pattern in a real,
  non-contrived use.
- **Fixtures as static factory extensions**, one per model
  (`WorldState.stub(...)`, presumably `Invasion.stub()`, `VoidTrader.stub()`,
  etc. given the cross-references in `WorldState.stub`), all defaulting every
  parameter so a test only overrides what it cares about. New model types
  should get a matching `.stub()` in `Fixtures.swift` rather than
  constructing the full initializer inline in a test.

## Conventions for a new test file
1. Mirror the source path: `TennoWatchTests/<Layer>/<TypeName>Tests.swift`.
2. `@Suite("<TypeName>")` wrapping `@Test` functions/methods, `@testable import TennoWatch`.
3. Stub the narrowest protocol the type under test depends on — don't reach
   for the real `APIManager`/`DefaultPersistencyService` unless the test is
   specifically about that integration (repository tests do use an
   in-memory `ModelContainer`, since SwiftData's own behavior is part of
   what's being tested there).
4. Add fixtures to the shared `Fixtures.swift` rather than duplicating stub
   construction per test file.

## Note on scope
Per [CLAUDE.md](../../CLAUDE.md): *"No tests yet — this is intentional while
fundamentals are still being built up. Ask before assuming either way when
that changes."* This is stale — the test suite already exists and covers a
meaningful (if partial) slice of the app. Worth updating that line, or
confirming whether it's meant to gate something more specific (e.g. UI/
snapshot tests, which genuinely don't exist yet) rather than tests in
general.
