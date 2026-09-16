# Layer: Theme & Shared UI

`TennoWatch/Theme/` — palette, reusable SwiftUI components, and the
one bit of UIKit-appearance bridging the app still needs.

## Palette
Colors are asset-catalog-backed (`Color.bg`, `.surface`, `.labelPrimary`,
`.labelSecondary`, `.divider`, `.accent` — referenced as `Color.x`
throughout, implying named color sets in the asset catalog that adapt to
light/dark automatically). `Theme/Palette.swift` layers semantic aliases on
top for state-specific meaning (`masteredIcon`, `unmasteredIcon`,
`lockedIcon`) rather than views picking `.labelSecondary`/`.accent` directly
— the icon color vocabulary is centralized in one place even though it
currently just forwards to two existing colors.
`PalettePreview.swift` (104 lines) is a SwiftUI preview-only swatch sheet for
eyeballing the palette in both color schemes — not shipped UI.

## Theme application (`TennoWatchApp.swift`)
`ThemePreference` (`system/light/dark`) drives `.preferredColorScheme(_:)` at
the `WindowGroup` root; `AppLanguage` drives `.environment(\.locale:)` **plus**
`.id(languagePreference)` on `MainView` — the `.id()` is what forces SwiftUI
to fully rebuild the view tree on a language change rather than leaving stale
localized strings cached in already-rendered views. Both preferences are read
via `@AppStorage` at the App level and again independently at the Settings
sheet level (two separate `@AppStorage` bindings to the same keys) — this
works because `@AppStorage` is backed by `UserDefaults`, a single source of
truth both call sites observe, not two independent copies of state.

`AppearanceProxies.configure()` — one-time UIKit appearance-proxy setup
(`UINavigationBar.appearance()`, `UITabBarItem.appearance()`) for large-title
and tab-bar label tinting, called once from `TennoWatchApp.init()`.
This exists because SwiftUI's own tab bar / large-title text color styling
API surface is still incomplete for this use case — one of the few
UIKit-interop points allowed under this project's "SwiftUI only, no UIKit
unless there's genuinely no SwiftUI equivalent" convention.

## Shared components (`Theme/Components/`)
- **`Surface`** — the card container (`Color.surface` background, 10pt
  corner radius, 12pt padding) used for every "summary card" across tabs
  (Mastery's rank card, Profile's identity card).
- **`ThemedList`** — `.themedList()` view modifier: hides the default list
  background, applies `Color.bg`/`Color.surface`/`Color.divider` to
  scroll/row/separator. Applied inconsistently today — `SettingsView` calls
  it, `MasteryView`/`ProfileView`/`WorldStateView` don't appear to (they use
  plain `List` styling). Worth a pass to decide if every list should use it,
  or if the difference is intentional (e.g. `.plain` list style used
  elsewhere for the drill-down screens' denser rows).
- **`FilterPills`** — generic `Hashable` option picker rendered as a
  horizontal row of capsule buttons, `@Binding var selection`. Used by
  Mastery's two detail screens for the missing/mastered/locked filter — the
  one genuinely reusable, generically-typed component in the app (works for
  any `Hashable` option type with a `title` closure, not hardcoded to one enum).
- **`ProgressBar`** — the XP/mastery progress bar (Mastery's rank card).
- **`SectionHeader`** — `SectionHeaderLabel`, the consistent section-header
  text styling used in every tab's `List`.
- **`LiveCountdownText`** — self-updating "time left" text, used in
  `CycleRowView` and `VoidTraderRowView` (picking activation vs. expiry
  depending on whether the trader has arrived yet). Notably *not* used by
  `FissureRowView` or the invasion rows — those render `WorldStateViewModel`'s
  static `timeLeft`/`expiry` strings computed once per fetch, so a fissure's
  countdown goes stale until the next pull-to-refresh while a cycle's ticks
  live. Worth a conscious call on whether that inconsistency matters (relic
  fissures are short-lived enough that a stale countdown is more noticeable
  than a stale day/night cycle).

## Conventions for adding a new shared component
Generic over `Content: View` (`Surface`) or a `Hashable` option type
(`FilterPills`) when the component's shape is reusable; a `View` extension
modifier (`themedList()`, `screenBackground()`) when it's really just a
bundle of standard modifiers applied together. Reach for `Color.x` semantic
names, never a raw `Color(.systemGray)`/hex literal in a tab-level View.

## Test coverage
None — SwiftUI view code isn't unit-tested in this app (expected; no
snapshot-test target exists yet). Verification is manual, via Xcode previews
and the simulator.
