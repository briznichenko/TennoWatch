# WarframeListener

A small iOS app that shows live Warframe status data (starting with active invasions), built as a personal learning project for modern Swift and iOS development.

## About

This repo exists to strengthen Swift and iOS skills — MVVM+C, Swift 6 strict concurrency, Combine, and (eventually) push notifications — using a real, changing data feed as the practice ground rather than static sample data. Shipping features fast is not the goal; understanding each piece as it's added is.

## Features

- **Invasions** — live list of active invasions (attacker/defender factions, rewards, completion progress), pulled from the Warframe status API.
- Push notifications for tracked events — planned, not wired up yet.

## Requirements

- Xcode 26 or later
- iOS 26.5+ (iPhone/iPad)
- Swift 6

## Getting Started

1. Clone the repo.
2. Open `WarframeListener.xcodeproj` in Xcode.
3. Build and run — no API key or configuration needed, the app talks to a public endpoint.

## Architecture

- **MVVM+C** (Model-View-ViewModel-Coordinator). Views bind to `@Observable` ViewModels; navigation will live in coordinators once there's more than one screen to navigate between.
- **Swift 6** language mode with strict concurrency, using this target's default `MainActor` isolation (Approachable Concurrency) to keep UI-facing code isolation-clean without sprinkling `@MainActor` everywhere.
- **Combine** powers the network/data layer — API calls return publishers that feed the ViewModels.
- **SwiftUI** only.

## Data Source

The app fetches from [`api.warframestat.us`](https://docs.warframestat.us/), a community-run API maintained by [Warframe Community Developers (WFCD)](https://github.com/WFCD). It wraps Digital Extremes' own public world-state feed — the same public data feed used by Digital Extremes' official companion app — rather than anything reverse-engineered from the game client.

## Legal

This is an unofficial, non-commercial, fan-made learning project. It is **not affiliated with, endorsed by, or sponsored by Digital Extremes**. WARFRAME® and all related game data, names, and assets are the property of Digital Extremes Ltd.

- All Warframe-related data displayed by this app is fetched live from a public API at runtime — no Warframe game data, images, or other assets are bundled with or committed to this repository.
- This project is for personal, educational, non-commercial use only, in line with Digital Extremes' [Content Policy](https://www.warframe.com/en/contentpolicy), [Terms of Use](https://www.warframe.com/en/terms), and [EULA](https://www.warframe.com/en/eula-us).
- The MIT license below covers the original source code in this repository only. It does not grant any rights to Warframe's name, trademarks, artwork, or game data.

## License

This project's source code is licensed under the [MIT License](LICENSE).
