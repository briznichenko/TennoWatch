# Layer: Networking

`WarframeListener/Networking/` — two files, the thinnest layer in the app.

## `Endpoints.swift`
- `EndpointProtocol` — `baseURL`, `path`, `queryItems`, computed `url` (can
  throw `URLError(.badURL)` if `URLComponents` construction fails).
- `Endpoint` enum, one case per API call the app makes:
  `.worldState(platform:)` and `.catalog(category:)` → `api.warframestat.us`;
  `.profile(playerId:)` → `api.warframe.com`. Two different base URLs live in
  the same enum's `baseURL` switch — deliberate, since there are only three
  endpoints total and a second enum would be overkill for a learning project
  at this size, but the seam is exactly where a second enum would go if a
  third API ever showed up.
- `Platform` (`pc, ps4, psn, xb1, swi, ns`) and `ItemCategory`
  (`weapons, warframes, items, mods`) are raw-string enums matching the
  community API's URL path segments verbatim.

## `APIManager.swift`
- `ServiceProtocol` — one method: `fetch<T: Decodable>(_:) async throws -> T`.
  This is the seam every repository depends on instead of `APIManager`
  directly, so tests can substitute a stub (see
  [Testing](Testing.md)/`APIManagerTests`).
- `APIManager` — plain `async`/`await` over `URLSession` (`.shared` by
  default, injectable). Success is `httpResponse.statusCode == 200` exactly
  — no retry, no handling for redirects, 304s, or anything else in the 2xx
  range; anything else throws `APIError.invalidResponse` with no status code
  or body attached, so failures are opaque to the caller/`ErrorManager`
  beyond "the request failed."
- Custom `JSONDecoder.dateDecodingStrategy`: ISO8601 with fractional seconds,
  plus one hand-rolled escape hatch — strings prefixed `+275760-09-13`
  (the .NET/MongoDB "max date" sentinel some fields use for "never expires")
  decode to `Date.distantFuture` instead of throwing. This is API-specific
  knowledge worth knowing about before touching any `Date?` field that comes
  from `warframestat.us` — a naive re-implementation would throw on that
  sentinel value.
- Imports `Combine` but doesn't use it — see the discrepancy note in
  [Specs/README.md](../README.md). Safe to drop the import.

## Conventions for adding a new endpoint
1. Add a case to `Endpoint`, wire `path`/`queryItems`/`baseURL` if it's a new
   host.
2. Call it through `ServiceProtocol.fetch(_:)` from a repository — never
   instantiate `APIManager` inside a ViewModel or View.
3. If the response has an unusual date sentinel or other quirk, extend the
   shared `decoder` in `APIManager`, don't hand-roll per-model decoding.

## Test coverage
`APIManagerTests` — covers the fetch/decode path and (per file size, 142
lines) likely the date-sentinel edge case and non-200 failure. This is the
one layer with reasonably proportionate test coverage relative to its size.
