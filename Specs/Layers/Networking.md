# Layer: Networking

`TennoWatch/Networking/` — two files, the thinnest layer in the app.

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
- `ServiceProtocol` exposes `fetch<T: Decodable>(_:) async throws -> T` and
  `clearCache()` (a default no-op for services without a cache).
  This is the seam every repository depends on instead of `APIManager`
  directly, so tests can substitute a stub (see
  [Testing](Testing.md)/`APIManagerTests`).
- `APIManager` uses `async`/`await` over an injectable `URLSession`. Its default
  ephemeral session waits for connectivity, with a 15-second request timeout and
  a 30-second resource timeout per attempt. It disables URLCache so the explicit
  TTL is the only client cache policy. Injected sessions keep their own configuration.
- Successful 2xx responses are decoded. Other HTTP responses throw
  `APIError.httpStatus(Int)`; non-HTTP responses throw `.invalidResponse`.
- GET requests retry at most twice for timeouts, connection loss, selected
  connection/DNS errors, and HTTP 408/429/500/502/503/504. Backoff is 1 then 2
  seconds plus up to 250ms jitter. `Retry-After` seconds and HTTP dates are honored;
  waits above 30 seconds return the HTTP error instead of retrying early.
  Offline errors, cancellation, permanent HTTP errors, and decoding errors do not retry.
- Successfully decoded response bytes are cached in memory per full URL and
  APIManager instance: world state for 30 seconds, catalog for one hour, profiles
  for zero seconds. Profile persistence remains in `PersistentProfileRepository`,
  so its force-refresh behavior still reaches the server. `no-store`/`no-cache`
  responses are excluded, and expired values are never returned on failure.
- `clearCache()` invalidates stored responses and prevents requests already in
  flight from repopulating the cache. World State and Openings manual refresh
  clear this cache before loading; Settings cache reset also invalidates it.
- An injected clock and async sleep closure make expiry/backoff deterministic
  in tests. Cancellation is checked before cache reads and after network awaits;
  cancellation of the normal `Task.sleep` stops backoff immediately.
- Custom `JSONDecoder.dateDecodingStrategy`: ISO8601 with fractional seconds,
  plus one hand-rolled escape hatch — strings prefixed `+275760-09-13`
  (the .NET/MongoDB "max date" sentinel some fields use for "never expires")
  decode to `Date.distantFuture` instead of throwing. This is API-specific
  knowledge worth knowing about before touching any `Date?` field that comes
  from `warframestat.us` — a naive re-implementation would throw on that
  sentinel value.

## Conventions for adding a new endpoint
1. Add a case to `Endpoint`, wire `path`/`queryItems`/`baseURL` if it's a new
   host.
2. Call it through `ServiceProtocol.fetch(_:)` from a repository — never
   instantiate `APIManager` inside a ViewModel or View.
3. If the response has an unusual date sentinel or other quirk, extend the
   shared `decoder` in `APIManager`, don't hand-roll per-model decoding.

## Test coverage
`APIManagerTests` covers date decoding, HTTP and transport retry classification,
retry limits and Retry-After, cancellation during backoff, TTL expiry, URL-key
isolation, profile bypass, no-store, and invalidation during an in-flight request.
