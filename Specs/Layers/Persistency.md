# Layer: Persistency

`WarframeListener/Persistency/` — SwiftData-backed local storage, wrapped
behind a protocol so repositories never touch `ModelContext` directly.

## The value/model pair (`ValueTypeConvertible.swift`)
Two tiny protocols, applied to almost every persisted type:
```swift
protocol ValueTypeConvertible: PersistentModel {
    associatedtype Value: Sendable
    var value: Value { get }
}
protocol PersistentModelConvertible {
    associatedtype Model: PersistentModel
    var model: Model { get }
}
```
Every `@Model` class (`ProfileDataModel`, `MasteryCatalogDataModel`, etc.)
conforms to `ValueTypeConvertible` and knows how to produce its plain-struct
`Value`. Every plain struct that gets persisted (`Profile`, `Intrinsics`,
`AccountStats`, `ProfileItemModel`, `MasterySourceModel`, ...) conforms to
`PersistentModelConvertible` and knows how to produce its `@Model`. This is
the mechanism that keeps `@Model` classes from ever leaking past the
persistency layer — repositories and everything above only ever see the
plain-struct `Value` side. **This is the pattern a new persisted type has to
follow**, and it's mechanical enough to script (see the scaffolding agent
proposal).

Convention observed across every pair: uniqueness/identity fields
(`accountID`, `displayName`, `tag`, `name`, `schemaVersion`) get
`@Attribute(.unique)`; relationships get an explicit `deleteRule` (almost
always `.cascade` — a profile's items/skills/missions die with the profile)
and an `inverse` key path back to the parent.

## `PersistencyService.swift`
```swift
protocol PersistencyService {
    func fetchModel<T: ValueTypeConvertible>(by:with:) async throws -> [T.Value]
    func saveValues<T: PersistentModelConvertible>(_:) async throws
    func saveValue<T: PersistentModelConvertible>(_:) async throws
    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T
}
```
`DefaultPersistencyService` is a `@ModelActor` — the one real actor-isolation
boundary in the app, since SwiftData's `ModelContext` isn't `Sendable` and
`@ModelActor` is the framework-blessed way to get safe concurrent access to
it. `fetchModel`/`saveValue(s)` are convenience wrappers around the generic
value/model conversion; `perform(_:)` is the escape hatch for anything more
specific than "fetch all" or "save one" — `CatalogRepository` uses it
heavily for predicate-based fetches and multi-step merge writes that need to
happen inside a single `ModelContext` transaction.

## What's actually persisted
- **`ProfileDataModel`** — one row per synced profile (`accountID` +
  `displayName` both unique — in practice there's one row total, since the
  app only ever tracks one player ID at a time). Cascades to items,
  intrinsics (`IntrinsicsDataModel`), missions.
- **`MasteryCatalogDataModel`** — exactly one row, ever. Seeded once from the
  bundled `masterycatalog.json` (see [Models](Models.md)) on first
  `CatalogRepository` access (`ensureCatalogSeeded`), never re-seeded after
  that — only merged against fresh profile data. `schemaVersion` is
  `@Attribute(.unique)`, which is really enforcing "only one catalog
  version can exist," not "catalog rows are unique per version."
- **`CatalogContainerModel`** / **`MasteryCategoryDataModel`** — the
  per-category breakdown (items and non-item sources respectively), owned by
  the single catalog row.

## Conventions for adding a new persisted type
1. Define the plain `Value` struct first (usually already exists as a
   network/domain model).
2. Add a matching `@Model` class, `ValueTypeConvertible` conformance on it,
   `PersistentModelConvertible` conformance on the struct.
3. Mark identity fields `@Attribute(.unique)`, relationships with explicit
   `deleteRule` + `inverse`.
4. Go through `PersistencyService`, never instantiate `ModelContainer`/
   `ModelContext` outside `AppDependencies` and test setup.

## Known gaps / TODOs
- No migration story yet — `schemaVersion` exists on the catalog model but
  nothing reads it to decide whether to re-seed vs. wipe-and-reseed on a
  version bump. Worth a conscious design pass before the bundled catalog
  JSON's `schemaVersion` ever actually changes.
- `MasteryCatalogDataModel.schemaVersion` being the unique-attribute rather
  than an explicit "singleton row" pattern (e.g. a fixed known ID) means two
  different schema versions could theoretically coexist as two rows if
  seeding logic changes — `ensureCatalogSeeded`'s `fetchCount > 0` guard is
  what actually enforces singleton-ness today, not the model itself.

## Test coverage
Exercised indirectly through `ProfileRepositoryTests` and
`CatalogSyncServiceTests` (both use an in-memory `ModelContainer`). No tests
target `PersistencyService`/`DefaultPersistencyService` in isolation.
