# TennoWatch — Specs

Specs for the current state of the app, split along the two
axes that matter for finding things: **Tabs** (a user-facing feature, top to
bottom) and **Layers** (a horizontal slice shared by multiple tabs).

These are descriptive, not aspirational — they document what's built today so
future work has a stable baseline to diff against.

## Tabs

| Spec | Screen(s) | Depends on |
|---|---|---|
| [WorldState](Tabs/WorldState.md) | Cycles, invasions, fissures, sorties, Nightwave, Void Trader | `WorldStateRepository` |
| [Mastery](Tabs/Mastery.md) | Rank progress, item categories, non-item sources, drill-down lists | `ProfileRepository`, `CatalogRepository` |
| [Openings](Tabs/Openings.md) | Time-sensitive vs. permanent unmastered items | `ProfileRepository`, `CatalogRepository`, `WorldStateRepository`, `OpeningsMatchingService` |
| [Profile](Tabs/Profile.md) | Identity card, intrinsics, items, missions, account stats | `ProfileRepository` |
| [Settings](Tabs/Settings.md) | Theme, language, account, catalog refresh | `PersistencyService`, `CatalogRepository`, `ProfileRepository` |

Settings is not a `Tab` in `MainView` — it's a sheet presented from Profile's
toolbar. It gets its own spec because it's a distinct feature surface with its
own ViewModel and screen, same as the four tabs.

## Layers

| Spec | Folder | Purpose |
|---|---|---|
| [Networking](Layers/Networking.md) | `Networking/` | `APIManager` + `Endpoint` — talks to `api.warframestat.us` and `api.warframe.com` |
| [Persistency](Layers/Persistency.md) | `Persistency/` | SwiftData `@ModelActor` service + value/model conversion pair |
| [Repositories](Layers/Repositories.md) | `Repositories/` | One repository per data domain; owns cache policy, fronts networking + persistency |
| [Services](Layers/Services.md) | `Services/` | Stateless business logic (catalog↔profile merge, openings matching, error queue) |
| [Models](Layers/Models.md) | `Models/` | Network DTOs, SwiftData-adjacent value models, view-facing derived models |
| [Theme & Shared UI](Layers/Theme-and-UI-Components.md) | `Theme/` | Palette, reusable SwiftUI components, list styling |
| [Localization](Layers/Localization.md) | `Resources/` | `Strings` namespace + `Localizable.xcstrings` + runtime language switch |
| [Testing](Layers/Testing.md) | `TennoWatchTests/` | Swift Testing coverage, fixtures, what's covered vs. not |

## Cross-cutting architecture (applies to every tab)

- **MVVM+C.** View → `@Observable` ViewModel → Repository protocol →
  (Service +) Networking/Persistency. No coordinator yet (single-level
  navigation only); 
- **Dependency injection** is manual, via [`AppDependencies`](../TennoWatch/AppDependencies.swift),
  constructed once in `TennoWatchApp` and threaded down through
  `MainView` → tab `View.init` → `ViewModel.init`. There is no DI container.
- **Loading/error pattern**, repeated in every top-level ViewModel:
  `isLoading` toggled with `defer`, failures caught and pushed to the shared
  `ErrorManager` (never thrown to the view), and the view attaches
  `.handleErrorAlert(with: viewModel.errorManager)` once at the top.
- **List → detail navigation** is done by the parent ViewModel exposing a
  `make*DetailViewModel(...)` factory rather than passing repositories further
  down, e.g. `MasteryViewModel.makeCategoryDetailViewModel(for:)`.
- **Swift 6 strict concurrency**, target-wide default `MainActor` isolation
  (Approachable Concurrency) — most types need no explicit `@MainActor`.
  `DefaultPersistencyService` is the one actor doing real off-main work
  (`@ModelActor`).
- **Xcode project uses file-system-synchronized groups**
  (`PBXFileSystemSynchronizedRootGroup`), not manually-maintained `PBXFileReference`
  lists. Any `.swift` file dropped into the right folder is picked up by Xcode
  automatically — no `.pbxproj` editing needed for new files. 
