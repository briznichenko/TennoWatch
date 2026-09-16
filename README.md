# WarframeListener

A small iOS app built against live Warframe status and profile data, built as a personal learning project for modern Swift and iOS development.

## About

This repo exists to strengthen Swift and iOS skills — MVVM+C, Swift 6 strict concurrency, SwiftData, and (potentially) push notifications. 
I needed a tool to track my Mastery progress in Warframe, so this project became an opportunity to build it while strengthening my Swift and iOS skills.
The app uses Warframe’s real, constantly changing data feed as its foundation. Rather than building isolated sample features, each framework and architectural decision is introduced as part of solving an actual problem I have with the game.

## Features

- **World State** — live invasions, fissures, sorties, Nightwave challenges, the Void Trader, and the various open-world day/night cycles (Cetus, Vallis, Cambion, Zariman), pulled from the Warframe status API.
- **Mastery** — tracks mastery progress against a locally generated item catalog, broken down by category and source, including intrinsics and Steel Path variants.
- **Openings** — cross-references your remaining mastery items against live world state to surface time-sensitive ways to get them (an invasion carrying the item as a reward, the Void Trader stocking it, etc).
- **Profile** — pulls a player's public stats, missions, and inventory from the Warframe profile API.
- **Settings** — theme (system/light/dark), language, and manual mastery-catalog refresh with version/generation-date info.
- Push notifications for tracked events — planned, not wired up yet.

## Requirements

- Xcode 26 or later
- iOS 26.5+ (iPhone/iPad)
- Swift 6

## Getting Started

1. Clone the repo.
2. Open `WarframeListener.xcodeproj` in Xcode.
3. Build and run — no API key or configuration needed, the app talks to public endpoints.

The Mastery catalog itself is generated offline: [Scripts/itemMapper.py](Scripts/itemMapper.py) maps game item paths to display names into [Generated/ExternalData.swift](Generated/ExternalData.swift), which is checked into the repo. You only need to re-run it after a game update adds new items.

## Architecture

- **MVVM+C** (Model-View-ViewModel-Coordinator). Views bind to `@Observable` ViewModels; navigation will live in coordinators once there's more than one screen to navigate between.
- **Swift 6** language mode with strict concurrency, using this target's default `MainActor` isolation (Approachable Concurrency) to keep UI-facing code isolation-clean without sprinkling `@MainActor` everywhere.
- **Networking** is plain `async`/`await` over `URLSession` ([APIManager.swift](WarframeListener/Networking/APIManager.swift)) — no Combine in the request path.
- **SwiftData** backs persistence, via a `@ModelActor` service ([PersistencyService.swift](WarframeListener/Persistency/PersistencyService/PersistencyService.swift)) and a `ValueTypeConvertible`/`PersistentModelConvertible` pair that keeps plain value types at the repository/ViewModel boundary instead of leaking `@Model` classes upward.
- **SwiftUI** only.

## Testing

Swift Testing, covering networking, repositories, sync/matching services, and one ViewModel so far (`WarframeListenerTests/`). Coverage is intentionally partial while the app is still taking shape.

## Data Source

- World state and the mastery catalog come from [`api.warframestat.us`](https://docs.warframestat.us/), a community-run API maintained by [Warframe Community Developers (WFCD)](https://github.com/WFCD). It wraps Digital Extremes' own public world-state feed — the same public data feed used by Digital Extremes' official companion app — rather than anything reverse-engineered from the game client.
- Profile data comes from Digital Extremes' own public profile-viewer endpoint (`api.warframe.com`), the same one the in-game and web profile viewers use.

## Legal

This is an unofficial, non-commercial, fan-made learning project. It is **not affiliated with, endorsed by, or sponsored by Digital Extremes**. WARFRAME® and all related game data, names, and assets are the property of Digital Extremes Ltd.

- All Warframe-related data displayed by this app is fetched live from a public API at runtime — no Warframe game data, images, or other assets are bundled with or committed to this repository.
- This project is for personal, educational, non-commercial use only, in line with Digital Extremes' [Content Policy](https://www.warframe.com/en/contentpolicy), [Terms of Use](https://www.warframe.com/en/terms), and [EULA](https://www.warframe.com/en/eula-us).
- The MIT license below covers the original source code in this repository only. It does not grant any rights to Warframe's name, trademarks, artwork, or game data.

## License

This project's source code is licensed under the [MIT License](LICENSE).
