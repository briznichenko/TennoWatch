# Layer: Theme & Shared UI

`TennoWatch/Theme/` contains semantic colors, layout metrics, and reusable SwiftUI
components. Platform interop lives in `Platform/`.

## Palette and layout

Asset-backed colors include `Color.bg`, `.surface`, `.labelPrimary`,
`.labelSecondary`, `.divider`, and `.accent`. `Palette.swift` adds mastery-state
aliases and Archon colors. `DashboardStyle.swift` supplies dashboard palette and
shared hero/card/metric/header styles. `LayoutMetrics.swift` centralizes spacing,
row dimensions, and other shared layout values; feature-specific values can stay
near their views. `PalettePreview` provides a preview swatch sheet.

## Theme and language application

`TennoWatchApp` reads theme and language through `@AppStorage` and applies
`.preferredColorScheme` and `.environment(\.locale)` to main and Settings content.
Changing language also changes view identity through `.id(languagePreference)`,
recreating content so existing presentation state does not retain old strings.
Settings binds to the same UserDefaults keys. A separate cache-reset identity
recreates app content after a successful storage reset.

## Platform boundary

- `AppScenes` composes the main window, macOS Settings scene, and Lotus
  `MenuBarExtra`. `MenuBarContent` opens the main window or Settings, or quits.
- `AppPresentation` provides platform-specific grid columns, padding, and tab role.
- `View+Platform` adapts tab/list styles, navigation titles, and refresh controls.
- `AppSettingsButton` opens the macOS Settings window or presents the iOS sheet;
  `SettingsSceneContent` supplies the selected account in the macOS window.
- `AppearanceProxies.configure()` sets iOS navigation/tab appearance at startup.
- `EmbeddedWikiWebView` wraps `WKWebView` through `UIViewRepresentable` on iOS
  and `NSViewRepresentable` on macOS. `WikiCoordinator` presents the shared browser.

Feature views use these platform APIs without platform compilation checks.

## Shared components

- `DashboardHero`, dashboard metrics/headers, and feature cards provide the current
  dashboard layout. Grids adapt to platform and accessibility text size.
- `Surface` is a generic content container with 12-point padding and a 10-point
  corner radius. It remains available alongside the dashboard components.
- `ThemedList` and `.themedList()` apply shared background/row/separator styling;
  scroll-view dashboards apply their own background and layout.
- `FilterPills` binds a generic Hashable option to capsule buttons; Mastery detail
  screens use it for mastery-state filtering.
- `ProgressBar` renders progress. `SectionHeaderLabel` and `DashboardSectionHeader`
  provide section headings for their respective layouts.
- `LiveCountdownText` uses a periodic `TimelineView`, updating every second or
  minute and clamping elapsed countdowns to zero. A ticking label does not reload
  its underlying API data. `FissureRowView` currently shows node/mission/enemy and
  storm state, without an expiry countdown.
- `LotusMark` and `LotusLoaderView` provide shared branding/loading presentation.
- `ItemWikiLink` connects item actions to the environment's `WikiCoordinator`.

## Conventions and verification

Use semantic palette and shared layout values in feature views. Make components
generic when their content or selection genuinely varies, and use view modifiers
for shared bundles of styling. Keep UIKit/AppKit/WebKit integration in `Platform/`.

There is no UI/snapshot test target. Verify layout through previews and on macOS
and an iOS simulator, including accessibility text sizes and both color schemes.
