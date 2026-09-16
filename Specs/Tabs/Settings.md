# Tab: Settings

Not a `Tab` — presented as a `.sheet` from [Profile](Profile.md)'s toolbar
gear icon. Documented separately because it's a distinct feature surface
with its own ViewModel, not because it has its own tab bar entry.

## Purpose
App-level preferences (theme, language) plus manual control over the
mastery-catalog sync that the Mastery/Openings tabs otherwise trigger
implicitly on every fetch.

## Entry point
`ProfileView` → `isShowingSettings` sheet → [`SettingsView`](../../WarframeListener/Views/Settings/SettingsView.swift),
constructed with `persistencyService`, `catalogRepository`, `profileRepository`,
`errorManager` — the only screen that touches `PersistencyService` directly
rather than going through a repository, because it needs raw access to
`MasteryCatalogDataModel` metadata (game version, generated-at date) that no
repository method currently exposes.

## Screen — `SettingsView`
Single `List`, four sections:
- **Appearance** — `Picker` bound directly to `@AppStorage("themePreference")`
  (`ThemePreference: system/light/dark`). No ViewModel involvement — this is
  the one piece of UI state in the app that's pure `@AppStorage`, not routed
  through an `@Observable` ViewModel.
- **Language** — same pattern, `@AppStorage(AppLanguage.storageKey)`. Setting
  this triggers `Strings`' bundle lookup to switch (see
  [Localization](../Layers/Localization.md)) — takes effect live, no restart.
- **Account** — read-only, shows `displayName` passed in from `ProfileView`
  (not re-fetched here).
- **Catalog** — `gameVersion` + `catalogGeneratedAt` (both `nil`-coalesced to
  a placeholder until `loadCatalogInfo()` resolves), a refresh button
  disabled while `isRefreshing`, and a `statusText` line that's declared but
  — worth checking — appears to never actually get set anywhere in
  `SettingsViewModel`; likely a stub for a "refreshed N items" message that
  wasn't wired up yet.

## ViewModel — `SettingsViewModel`
- `loadCatalogInfo()` — reads the *first* `MasteryCatalogDataModel` row via
  `persistencyService.fetchModel(by:)` directly (bypassing `CatalogRepository`
  entirely) for `gameVersion`/`catalogGeneratedAt`. There's exactly one
  catalog row ever persisted (see [Persistency](../Layers/Persistency.md)),
  so `.first` is safe today but is an implicit assumption this ViewModel
  relies on without enforcing it.
- `refreshCatalog()` — force-refreshes the profile, then
  `catalogRepository.syncMasteryCatalog(with:)`, then reloads catalog info.
  This is the *only* place in the app that triggers a full mastery-catalog
  resync outside of the Mastery/Openings tabs' own implicit sync-on-fetch.

## Known gaps / TODOs
- `statusText` is declared, read by the view, but never assigned in
  `SettingsViewModel` — either dead state or an unfinished "last refresh
  result" message.
- No way to reset/clear local persistence (useful for a learning-project
  debug menu, arguably out of scope for a real settings screen).
- Theme/language use `@AppStorage` directly rather than being surfaced on
  `SettingsViewModel` — inconsistent with the rest of the app's "ViewModel
  owns all state" convention, though arguably correct here since
  `@AppStorage` is exactly the right tool for simple persisted UI prefs and
  routing it through a ViewModel would add a layer for no benefit.

## Test coverage
None. No repository/service layer of its own to test independently — its
only non-trivial logic (`refreshCatalog`'s three-step sequence) is really
exercising `ProfileRepository`/`CatalogRepository`, which have their own
tests.
