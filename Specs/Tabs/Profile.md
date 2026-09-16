# Tab: Profile

## Purpose
Pulls a player's public stats, missions, and inventory from Digital
Extremes' own profile-viewer endpoint (`api.warframe.com`, not the
community `warframestat.us` API everything else uses). Also the tab that
hosts the Settings entry point (gear icon → sheet).

## Entry point
`MainView` → `Tab("Profile")` → [`ProfileView`](../../WarframeListener/Views/Profile/ProfileView.swift),
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
- `#if DEBUG` seeds `playerId` with a hardcoded test account ID at init, so
  the tab isn't empty on first run in development. **This is the
  `523b73b91a4d806878000000` the README flags as the known gap** — there's
  no search/lookup flow, just this field.
- `fetchProfile(forceRefresh:)` guards on `playerId.isEmpty` and pushes a
  `ProfileError.noPlayerId` to `errorManager` rather than silently no-op-ing
  — the only tab that treats "missing required input" as a user-facing error
  rather than an empty state.
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
  seeded with a debug value. This is the single most likely "next real
  feature" for this tab.
- No validation on the player-ID field format (Warframe account IDs are
  24-char hex Mongo ObjectIDs) — a malformed ID just round-trips to a normal
  fetch failure via `errorManager`.

## Test coverage
None directly (no `ProfileViewModelTests`). `ProfileRepositoryTests` covers
the repository layer's cache/force-refresh logic, which is most of this
tab's actual risk surface.
