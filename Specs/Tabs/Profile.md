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
1. **`ProfileView`** — root. Identity card (`Surface`: display name, player
   ID, rank/missions/kills stat triplet), an editable player-ID text field
   (`onSubmit` re-fetches), and a stats section with conditional
   `NavigationLink`s — each row only appears if that data category is
   non-empty (no intrinsics row if `intrinsicGroups` is empty, etc.).
2. **`IntrinsicsView`** — pushed from the intrinsics row, grouped by
   `IntrinsicGroup` (operator/necramech schools), `IntrinsicRowView` per
   intrinsic with rank/max-rank.
3. **`ProfileItemsListView`** — pushed, list of `ProfileItemStat` (kills per
   weapon/warframe), own tiny ViewModel (`ProfileItemsListViewModel`) that
   just holds the already-fetched array — no repository, no fetch, exists
   purely to keep the row-mapping logic out of the view.
4. **`ProfileMissionsListView`** — same shape, for `MissionStat`.
5. **`ProfileAccountStatsView`** — pushed, flat `AccountStatRow` list (no
   dedicated ViewModel — takes `rows: [AccountStatRow]` directly).
6. **`SettingsView`** — presented as a `.sheet`, not pushed. See
   [Settings](Settings.md).

## ViewModel — `ProfileViewModel`
- `playerId: String` is the one piece of *user-editable* state living
  directly on a top-level ViewModel in this app (everything else is
  read-only display state) — bound two-way to the `TextField`.
- `load()` restores the saved active profile without requiring a network request. A first launch creates a local manual profile with a persisted UUID.
- `savedProfiles` backs the profile picker. Selection is cached and works offline; swipe-to-delete asks for confirmation and removes that profile's owned progress.
- `fetchProfile(forceRefresh:)` trims the input ID and imports or refreshes that account. The identity card displays the saved account ID independently of the editable input.
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
- README-documented: no player search/lookup UI, just a raw ID text field
  for importing another profile.
- No validation on the player-ID field format (Warframe account IDs are
  24-char hex Mongo ObjectIDs) — a malformed ID just round-trips to a normal
  fetch failure via `errorManager`.

## Test coverage
None directly (no `ProfileViewModelTests`). `ProfileRepositoryTests` covers
the cache/force-refresh logic. `ProfileIsolationTests` verifies switching, deletion, the manual profile, and delayed-request selection safety.
