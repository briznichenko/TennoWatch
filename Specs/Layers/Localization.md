# Layer: Localization

`TennoWatch/Resources/` — `Strings.swift`, `AppLanguage.swift`,
`Localizable.xcstrings`.

## `Strings` namespace
```swift
struct Strings {
    private init() {}
    struct WorldState { private init() }
        static var title: String { Strings.string("world_state_title_key", "World state") }
        ...
    }
    struct Mastery { ... }
    struct Openings { ... }
    struct Profile { ... }
    struct Settings { ... }
    struct Theme { ... }
    struct Language { ... }
    struct ErrorAlert { ... }
    struct Main { ... }  // tab titles
}
```
One nested, non-instantiable `struct` per tab/feature, each member a
computed `static var` (or a `static func` for parameterized strings, e.g.
`Strings.Mastery.rankBadge(_ rank: Int)`) that calls a `fileprivate static
func string(_ key:_ defaultValue:)`. That helper does a manual
`Bundle(path:)` lookup for the *current* `AppLanguage`'s `.lproj`, falling
back to `.main` if the language is `.system` or the bundle can't be found —
this is what makes runtime language switching work without an app restart
(see the `Theme.md` note on `.id(languagePreference)`), since standard
`NSLocalizedString`/`String(localized:)` only responds to `Locale`/`environment`
changes for text created *after* the switch, and this bundle-swap approach
sidesteps that.

Every string carries its **English text inline as the default value** —
`Localizable.xcstrings` doesn't need an entry to avoid a crash or a visibly
missing string; a missing key just falls back to the English default passed
at the call site. This is a deliberate resilience choice: a new string added
to `Strings.swift` without a matching `.xcstrings` entry degrades to correct
English rather than a broken UI, at the cost of Ukrainian not being
translated until someone adds the entry.

## `AppLanguage`
`system / english / ukrainian` — two real languages plus `system` (defers to
`Locale`). `Locale(identifier:)` for `.english`/`.ukrainian`, `nil` for
`.system` (meaning "don't override, let `.environment(\.locale)` fall through
to the device's own"). `AppLanguage.current` reads `UserDefaults` directly
via `storageKey`, independent of `@AppStorage` — used by `Strings.currentBundle`,
which needs synchronous, non-view-context access to the current language.

## Conventions for adding new UI text
1. Add a `static var`/`static func` under the right nested `struct` in
   `Strings.swift`, following the existing `"<feature>_<name>_key"` key
   naming convention, with the correct English text as the default value.
2. Never inline a string literal directly in a View — every user-visible
   string in the codebase (following the pattern established so far) goes
   through `Strings`.
3. Add the corresponding entry (with a Ukrainian translation, if available)
   to `Localizable.xcstrings` — not required for the app to build or run
   correctly (see the fallback behavior above), but required for the string
   to actually appear in Ukrainian rather than falling back to English.

## Known gaps / TODOs
- No way to verify at build time that every `Strings.x` key actually has a
  `Localizable.xcstrings` entry — a forgotten entry silently ships
  English-only for that string in the Ukrainian locale, with no warning.
  This is exactly the kind of check a lightweight script/agent could run in
  CI or pre-commit (diff `Strings.swift` keys against `.xcstrings` keys).

## Test coverage
None. No test asserts `Strings.currentBundle`'s fallback behavior or that
every declared key round-trips through `Localizable.xcstrings`.
