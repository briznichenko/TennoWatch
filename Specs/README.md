# TennoWatch — Specs

Specs for the current state of the app, split along the two
axes that matter for finding things: **Tabs** (a user-facing feature, top to
bottom) and **Layers** (a horizontal slice shared by multiple tabs).

These are descriptive, not aspirational — they document what's built today so
future work has a stable baseline to diff against.

## Tabs

| Spec | Screen(s) | Depends on |
|---|---|---|
| [WorldState](Tabs/WorldState.md) | World-state dashboard, drill-downs, potential Prime releases | `WorldStateRepository`, `VoidTraderNotificationScheduler` |
| [Mastery](Tabs/Mastery.md) | Rank progress, item categories, non-item sources, drill-down lists | `ProfileRepository`, `CatalogRepository` |
| [Openings](Tabs/Openings.md) | Time-sensitive vs. permanent unmastered items | `ProfileRepository`, `CatalogRepository`, `WorldStateRepository`, `OpeningsMatchingService` |
| [Profile](Tabs/Profile.md) | Identity card, intrinsics, items, missions, account stats | `ProfileRepository` |
| [Settings](Tabs/Settings.md) | Theme, language, notifications, account, catalog refresh, storage reset | Persistence, repositories, notification services |

Settings is a separate feature surface: a sheet from Profile on iOS and a native
Settings window on macOS. The app has four tabs.

## Layers

| Spec | Folder | Purpose |
|---|---|---|
| [Networking](Layers/Networking.md) | `Networking/` | `APIManager` + `Endpoint` — talks to `api.warframestat.us` and `api.warframe.com` |
| [Persistency](Layers/Persistency.md) | `Persistency/` | SwiftData `@ModelActor` service + value/model conversion pair |
| [Repositories](Layers/Repositories.md) | `Repositories/` | One repository per data domain; owns cache policy, fronts networking + persistency |
| [Services](Layers/Services.md) | `Services/` | Business logic, shared error state, local notifications |
| [Models](Layers/Models.md) | `Models/` | Network DTOs, SwiftData-adjacent value models, view-facing derived models |
| [Theme & Shared UI](Layers/Theme-and-UI-Components.md) | `Theme/` | Palette, reusable SwiftUI components, list styling |
| [Localization](Layers/Localization.md) | `Resources/` | `Strings` namespace + `Localizable.xcstrings` + runtime language switch |
| [Testing](Layers/Testing.md) | `TennoWatchTests/` | Swift Testing coverage, fixtures, what's covered vs. not |

## Cross-cutting architecture

- **MVVM+C.** Views own `@Observable` ViewModels; ViewModels use repository
  protocols. `MasteryCoordinator` owns a `NavigationPath` with typed destinations,
  including the mastery breakdown. `WikiCoordinator` owns wiki-sheet presentation
  shared through the environment. Other tab drill-downs use inline navigation.
- **Dependency injection** is manual. [`AppDependencies`](../TennoWatch/AppDependencies.swift)
  constructs shared dependencies; composition views construct ViewModels and pass
  them into feature views. Mastery's parent ViewModel supplies detail ViewModel factories.
- **Loading and errors.** Top-level ViewModels expose loading state and route failures
  to the shared `ErrorManager`; views attach `.handleErrorAlert(with:)`. Cancellation
  is silent. User-facing error mapping and startup failure handling are covered by
  `AppErrorsTests`.
- **Swift 6 concurrency.** Default actor isolation is nonisolated, with Approachable
  Concurrency enabled. UI state explicitly uses `@MainActor`; Observation itself
  does not provide isolation. Profile/Catalog repositories, the network cache, and
  the notification scheduler use actors. `DefaultPersistencyService` is a
  `@ModelActor`: synchronous graph mutations and conversions stay inside its context,
  and `Sendable` values cross the boundary. See [Persistency](Layers/Persistency.md).
- **Platform adaptation** lives in `Platform/`, including scenes, refresh controls,
  Settings presentation, appearance proxies, and the embedded wiki web view.
- **File-system-synchronized Xcode groups** pick up Swift files placed in the
  corresponding source/test folders without manual project-file entries.
