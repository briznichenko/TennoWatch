# TennoWatch

Personal learning project. The point of this repo is to strengthen Swift and
iOS/macOS skills, and Claude Code working habits, along the way — it is not
a race to ship features. Expect a steep learning curve toward modern
practices, and treat that as the goal, not friction to route around.

## Purpose

A small app against the public Warframe status API
(https://api.warframestat.us) — starting with live invasion data.

## How to work here

- Prefer current APIs and idiomatic Swift 6 over familiar/older patterns,
  but do not overcomplicate. The priority is understanding each piece, not
  maximizing architecture. Simple and correct beats clever.
- When introducing a modern-Swift concept for the first time in this repo
  (Observation, structured concurrency, actor isolation, etc.), briefly say
  what problem it solves and what the older approach looked like.
- Small, understandable steps over big-bang changes.

## Stack

- **MVVM+C** — Model-View-ViewModel-Coordinator. Views bind to ViewModels;
  navigation belongs in coordinators, not views. There is only one screen so
  far, so no coordinator exists yet — add it once there is real navigation
  to coordinate, not preemptively.
- **Swift 6** language mode, strict concurrency. This target's default actor
  isolation is MainActor (Approachable Concurrency), which keeps most
  UI-facing code isolation-clean without manual `@MainActor` annotations
  everywhere.
- **Combine** for the network/data layer — publishers for API calls, feeding
  `@Observable` ViewModels that views read.
- **Push notifications** (APNs) — planned, not wired up yet.

## Conventions

- `@Observable` for ViewModels, not `ObservableObject` / `@Published`.
- SwiftUI only; no UIKit unless there's genuinely no SwiftUI equivalent.

## Testing

No tests yet — this is intentional while fundamentals are still being built
up. Ask before assuming either way when that changes.
