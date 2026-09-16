# Layer: Models

`WarframeListener/Models/` plus, notably, a chunk of domain models that
actually live under `Persistency/` instead — see the organizational note
below before assuming everything domain-shaped is in `Models/`.

## Three tiers of model
1. **Network DTOs** — `Decodable` (aliased `NetworkModel`), mirror the
   external API shape closely, including original `CodingKeys` where the
   community API or DE's profile API use different casing
   (`ProfileInfoModel`'s `PascalCase` keys). Examples: `ProfileModel`,
   `ProfileInfoModel`, everything in `WorldState.swift`
   (`ArchimedeaMission`, `Alert`, `Invasion`, `Fissure`, ...),
   `MasteryCatalogContainer`.
2. **Domain/value models** — plain structs, not `Decodable`, derived from
   DTOs or built by services. Examples: `MasteryItem`, `MasteryCatalog`,
   `CatalogContainer`, `MasteryCategoryModel`, `TimeSensitiveOpening`.
   Most of these also conform to `PersistentModelConvertible` (see
   [Persistency](Persistency.md)).
3. **View-facing derived models** — built by ViewModels, not stored anywhere
   (`WorldCycleDisplay`, `InvasionPlanetGroup`, `MasteryRankProgress`,
   `OpeningsItemCategorySummary`). These live in the ViewModel files
   themselves, not `Models/` — see each tab's spec.

## Organizational quirk worth knowing
`MasteryItem`, `MasteryCatalog`, `MasteryCatalogSummary`,
`CatalogContainerSummary`, and `MasteryCategorySummary` are defined inside
`Persistency/ProfileItemDataModel.swift` and `Persistency/MasteryCatalogDataModel.swift`,
next to their `@Model` counterparts — not in `Models/`. This isn't
inconsistency for its own sake: each of these types is defined directly
beside its `PersistentModelConvertible` extension, so the value type and its
persistence mapping are colocated and reviewed together. But it does mean
"where's `MasteryItem` defined" isn't answered by looking in `Models/` — a
scaffolding agent or a new contributor needs to know persisted domain models
live with their `@Model` pair, not in the models folder.

## Key domain model: `MasteryItem`
The unit everything in Mastery/Openings is built from. Notably, **mastery
rank is computed, not stored** — `rank` is derived from `xp` (read off the
matched `ProfileItemModel`, `0` if never matched) via
`Int(Double(xp / catalogItemModel.xpPerRankSq).squareRoot())`, clamped to
`catalogItemModel.maxRank`. `masteryState` (mastered/unmastered/partially
mastered/unobtainable) is a pure function of `rank` and `obtainable` — there
is no separate "is this mastered" flag anywhere in the item's own storage,
it's recomputed every access. This means any XP-formula bug shows up as
wrong mastery state everywhere at once, and there's no test pinning this
formula against a known catalog item + XP value (see
[Testing](Testing.md)).

## `CatalogItemModel.Category`
A 20-case raw-string enum matching the generated catalog's category keys
verbatim (`Suits`, `SpaceSuits`, `LongGuns`, `ZAW`, `KDRIVE`, ...), each with
a hand-written `displayName` (lowercase, singular: `"warframe"`,
`"archwing"`, `"primary"`...). Adding a new obtainable item category means
adding both a case and its display name — there's no derivation from the
raw value.

## Extensions layer (`Extensions/`)
Small, single-purpose, worth knowing about before reinventing:
- **`Date+Ex.swift`** — `timeLeftDescription`, abbreviated
  day/hour/minute countdown via `DateComponentsFormatter`. Used everywhere a
  cycle/fissure/Void-Trader expiry needs a "2h 15m" string.
- **`String+Ex.swift`** — `sentenceCased` (capitalize first letter only,
  used for category display names throughout Mastery/Openings);
  `nodeNameAndPlanet` (parses `"Name (Planet)"` node strings, used for
  invasion grouping); `spacedByCamelCase` (splits a camelCase/path-like
  identifier into words — for any raw API identifier that needs to become
  readable text without a manual display-name mapping).
- **`URL+Ex.swift`** — `URL(_:StaticString)`, a `preconditionFailure`-on-
  invalid init used for the two hardcoded `Endpoint` base URLs. Crashes
  instead of throwing because a malformed hardcoded literal is a
  programmer error caught at first launch, not a runtime condition.
- **`KeyedDecodingContainer+Omitting.swift`** — `@Omitted` property wrapper:
  a field that decodes to `nil` unconditionally, regardless of what's in the
  JSON (used on `MasterySourceModel.isMastered`, which only ever gets a real
  value from the sync service, never from the network response). This is how
  the same struct can be both a `Decodable` catalog DTO and a value that
  later carries computed mastery state, without a second "hydrated" type.
- **`ErrorAlertModifier.swift`** — see cross-cutting note in
  [Specs/README.md](../README.md); belongs conceptually here since it's a
  `View`/`ErrorManager` bridge, not UI chrome.

## Test coverage
No dedicated model tests — models are exercised indirectly through
`CatalogSyncServiceTests`, `OpeningsMatchingServiceTests`, and
`ProfileRepositoryTests`/`APIManagerTests` (decoding). The `MasteryItem.rank`
XP formula specifically has no direct test.
