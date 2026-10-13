# Tab: Profile

## Purpose
Pulls a player's public stats, missions, and inventory from Digital
Extremes' own profile-viewer endpoint (`api.warframe.com`, not the
community `warframestat.us` API everything else uses). Also the tab that
hosts the Settings entry point (gear icon → sheet).

## Entry point
`MainView` → `Tab("Profile")` → [`ProfileView`](../../TennoWatch/Views/Profile/ProfileView.swift),
constructed with `profileRepository` + `errorManager`, but also takes the
whole `AppDependencies` struct directly (the only tab view that does) purely
so it can build `SettingsView`'s dependencies when the sheet is presented.

## Screens
1. **`ProfileView`** — root. Identity hero card (display name, player ID,
   rank, missions, and kills) with a sync action for remote profiles, a
   saved-profiles section with an Add profile action, and a stats section with conditional
   `NavigationLink`s — each row only appears if that data category is
   non-empty (no intrinsics row if `intrinsicGroups` is empty, etc.).
   Saved-profile and stats rows share dashboard icons, text colors, and row
   padding. Accessibility sizes stack values below titles. The list uses
   inset groups on iOS and plain buttons on macOS; sync is a compact hero action.
   Local profiles omit remote rank/activity counters and remote sync.
2. **`AddProfileSheet`** — takes a player ID to import a remote profile.
   The ID draft and help prompt belong to the sheet. It closes after a
   successful import and stays open if the import fails. A view-owned task
   cancels the import when the sheet is dismissed; cancellation is silent.
3. **`IntrinsicsView`** — pushed from the intrinsics row, grouped by
   `IntrinsicGroup` (operator/necramech schools), `IntrinsicRowView` per
   intrinsic with rank/max-rank.
4. **`ProfileItemsListView`** — pushed, list of `ProfileItemStat` (kills per
   weapon/warframe), own tiny ViewModel (`ProfileItemsListViewModel`) that
   just holds the already-fetched array — no repository, no fetch, exists
   purely to keep the row-mapping logic out of the view.
5. **`ProfileMissionsListView`** — same shape, for `MissionStat`.
6. **`ProfileAccountStatsView`** — pushed, flat `AccountStatRow` list (no
   dedicated ViewModel — takes `rows: [AccountStatRow]` directly).
7. **`SettingsView`** — presented as a `.sheet`, not pushed. See
   [Settings](Settings.md).

## ViewModel — `ProfileViewModel`
- `AddProfileSheet` owns the editable player-ID draft in local `@State`.
- `load()` restores the saved active profile without requiring a network request. A first launch creates a local manual profile with a persisted UUID.
- `savedProfiles` backs the profile picker. Selection is cached and works offline; swipe-to-delete asks for confirmation and removes that profile's owned progress.
- `addProfile(playerID:)` trims and imports the entered ID, while `syncProfile()` force-refreshes the selected remote account. The identity card displays the selected account ID.
- If the last profile is deleted, the repository creates a fresh manual profile. A local profile is never sent to the remote profile endpoint; manual item editing remains future work.
- All other computed properties (`intrinsicGroups`, `itemStats`,
  `missionStats`, `accountStatRows`, `totalMissionsCompleted`, `totalKills`,
  `intrinsicsSummaryText`) are thin derivations off `profile: Profile?`,
  computed by the model layer (`Profile.intrinsicGroups` etc.) rather than
  here — the ViewModel mostly just forwards with a `?? []`/`?? 0` fallback
  for the nil-profile case.

## Data dependency
`ProfileRepository.getProfile(withPlayerId:forceRefresh:)` — the same
repository Mastery, Openings, and Settings all depend on for profile data,
making `ProfileRepository`'s daily-cache policy (see
[Repositories](../Layers/Repositories.md)) a shared cross-tab concern: a
force-refresh here also refreshes what Mastery/Openings will see next.

## Known gaps / TODOs
- README-documented: no player search/lookup UI, just a raw ID entry sheet
  for importing another profile.
- No validation on the player-ID field format (Warframe account IDs are
  24-char hex Mongo ObjectIDs) — a malformed ID just round-trips to a normal
  fetch failure via `errorManager`.

## Test coverage
None directly (no `ProfileViewModelTests`). `ProfileRepositoryTests` covers
the cache/force-refresh logic. `ProfileIsolationTests` verifies switching, deletion, the manual profile, and delayed-request selection safety.
