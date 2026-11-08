# Feature: Settings

## Purpose and entry points

Settings provides theme/language preferences, local Void Trader arrival reminders,
account information, catalog metadata/refresh, and storage reset. It is a sheet
from Profile on iOS and a native Settings window on macOS, also accessible through
the app menu and menu bar item.

`SettingsView` receives a `SettingsViewModel`, a display name, and an `onCacheCleared`
callback. `ProfileView` supplies the iOS presentation; `SettingsSceneContent` loads
the selected profile for the macOS window.

## Screen

The list has seven sections:

- **Appearance** — system/light/dark via `@AppStorage("themePreference")`.
- **Language** — system/English/Ukrainian via `@AppStorage(AppLanguage.storageKey)`;
  changes apply live. See [Localization](../Layers/Localization.md).
- **Notifications** — an `@AppStorage` toggle for local Void Trader arrival reminders.
- **Mastery** — an `@AppStorage` toggle to exclude locked items from completion
  counts and remaining XP, disabled by default. Earned XP is preserved.
- **Account** — the display name supplied by the parent.
- **Catalog** — version, optional generation date, and refresh with loading state.
- **Storage** — destructive cache clearing behind a confirmation dialog.

## ViewModel behavior

- `loadCatalogInfo()` reads the first `MasteryCatalogDataModel` value through
  `PersistencyService.fetchModel(by:)` for metadata. Catalogs are profile-owned;
  this read does not select the active profile's catalog.
- `refreshCatalog()` force-refreshes the active profile, then reloads metadata.
  Profile refresh prepares its catalog through the repository. It does not
  download a new bundled catalog or call `syncMasteryCatalog(with:)` directly.
- Enabling reminders requests notification permission, fetches world state, and
  asks `VoidTraderNotificationScheduler` to schedule a future arrival. Disabling
  reminders cancels the pending arrival notification. These are local notifications;
  APNs is not implemented.
- `clearCache()` deletes all persisted models, invalidates the world-state service's
  network cache, cancels the arrival reminder, and removes the app's UserDefaults
  domain, including profile selection and preferences. On success the view calls
  `onCacheCleared` so app content is recreated. Failures go to `ErrorManager`.

The ViewModel receives persistence, catalog/profile/world-state repositories,
notification service/scheduler, and the shared error manager. Theme and language
remain direct `@AppStorage` bindings, appropriate for persisted UI preferences.

## Known limitations

- Catalog metadata uses `.first` without filtering by active account. Multiple
  profile-owned catalogs can exist; this is not a guaranteed active-catalog lookup.
- The notification toggle stores intent before authorization/scheduling completes;
  a failure is presented but does not automatically turn the toggle off.
- Cache clearing spans several operations rather than one atomic transaction.

## Test coverage

No direct `SettingsViewModelTests`. `CacheClearingTests` verifies persisted-model
removal; profile and isolation suites cover repository behavior. The complete reset
sequence and notification-toggle flow have no dedicated tests.
