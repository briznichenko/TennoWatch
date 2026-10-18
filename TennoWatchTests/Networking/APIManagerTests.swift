//
//  APIManagerTests.swift
//  TennoWatchTests
//

import Testing
import Foundation
import Synchronization
@testable import TennoWatch

// MARK: - Assemble

private final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            fatalError("StubURLProtocol.handler was not configured for this test")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private func makeStubbedSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: configuration)
}

private struct StubModel: Decodable {
    let date: Date
}

@Suite("APIManager", .serialized)
struct APIManagerTests {
    // MARK: - Teardown

    // MARK: - State Lifecycle

    @Test("A fractional-second ISO8601 date decodes to the same value a standard ISO8601 parse would produce")
    func decodesFractionalSecondISO8601Date() async throws {
        let dateString = "2026-09-15T12:30:45.123Z"
        StubURLProtocol.handler = { request in
            let json = Data("{\"date\":\"\(dateString)\"}".utf8)
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            else {
                fatalError("Failed to construct stub response")
            }
            return (response, json)
        }
        let sut = APIManager(session: makeStubbedSession())

        let result: StubModel = try await sut.fetch(.worldState(platform: .pc))

        let referenceFormatter = ISO8601DateFormatter()
        referenceFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        #expect(result.date == referenceFormatter.date(from: dateString))
    }

    @Test("An exhausted server failure throws APIError")
    func nonSuccessStatusThrowsInvalidResponse() async {
        StubURLProtocol.handler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
            else {
                fatalError("Failed to construct stub response")
            }
            return (response, Data())
        }
        let sut = APIManager(session: makeStubbedSession(), sleep: { _ in })

        await #expect(throws: APIError.self) {
            let _: StubModel = try await sut.fetch(.worldState(platform: .pc))
        }
    }

    @Test("The distant-future sentinel date string decodes to Date.distantFuture")
    func decodesDistantFutureSentinel() async throws {
        StubURLProtocol.handler = { request in
            let json = Data("{\"date\":\"+275760-09-13T00:00:00.000Z\"}".utf8)
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            else {
                fatalError("Failed to construct stub response")
            }
            return (response, json)
        }
        let sut = APIManager(session: makeStubbedSession())

        let result: StubModel = try await sut.fetch(.worldState(platform: .pc))

        #expect(result.date == .distantFuture)
    }

    @Test("A malformed date string throws a DecodingError instead of crashing or silently defaulting")
    func malformedDateStringThrowsDecodingError() async {
        StubURLProtocol.handler = { request in
            let json = Data("{\"date\":\"not-a-date\"}".utf8)
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            else {
                fatalError("Failed to construct stub response")
            }
            return (response, json)
        }
        let sut = APIManager(session: makeStubbedSession())

        await #expect(throws: DecodingError.self) {
            let _: StubModel = try await sut.fetch(.worldState(platform: .pc))
        }
    }

    @Test("Malformed/truncated JSON throws a DecodingError")
    func malformedJSONThrowsDecodingError() async {
        StubURLProtocol.handler = { request in
            let json = Data("{\"date\":".utf8)
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            else {
                fatalError("Failed to construct stub response")
            }
            return (response, json)
        }
        let sut = APIManager(session: makeStubbedSession())

        await #expect(throws: DecodingError.self) {
            let _: StubModel = try await sut.fetch(.worldState(platform: .pc))
        }
    }

    @Test("Transient server failures retry twice with increasing backoff")
    func retriesServerFailures() async throws {
        let attempts = Mutex(0)
        StubURLProtocol.handler = { request in
            let attempt = attempts.withLock { $0 += 1; return $0 }
            return try makeResponse(request, status: attempt < 3 ? 503 : 200)
        }
        var delays: [TimeInterval] = []
        let sut = APIManager(session: makeStubbedSession(), sleep: { delays.append($0) })
        let value: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        #expect(value["value"] == 1)
        #expect(attempts.withLock { $0 } == 3)
        #expect(delays.count == 2)
        #expect((1...1.25).contains(delays[0]))
        #expect((2...2.25).contains(delays[1]))
    }

    @Test("A lost connection retries, while offline and cancellation errors fail immediately")
    func classifiesTransportFailures() async throws {
        for code in [URLError.networkConnectionLost, .notConnectedToInternet, .cancelled] {
            let attempts = Mutex(0)
            StubURLProtocol.handler = { request in
                let attempt = attempts.withLock { $0 += 1; return $0 }
                if attempt == 1 { throw URLError(code) }
                return try makeResponse(request)
            }
            let sut = APIManager(session: makeStubbedSession(), sleep: { _ in })
            do {
                let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
                #expect(code == .networkConnectionLost)
            } catch {
                #expect((error as? URLError)?.code == code)
                #expect(code != .networkConnectionLost)
            }
            #expect(attempts.withLock { $0 } == (code == .networkConnectionLost ? 2 : 1))
        }
    }

    @Test("Permanent HTTP failures and decoding errors never retry")
    func permanentFailuresDoNotRetry() async {
        for status in [401, 404, 200] {
            let attempts = Mutex(0)
            StubURLProtocol.handler = { request in
                attempts.withLock { $0 += 1 }
                return try makeResponse(request, status: status, body: "invalid JSON")
            }
            let sut = APIManager(session: makeStubbedSession(), sleep: { _ in
                Issue.record("A permanent failure must not wait for retry")
            })
            do {
                let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
                Issue.record("Expected failure")
            } catch {
                if status == 200 {
                    #expect(error is DecodingError)
                } else {
                    guard case APIError.httpStatus(let actual) = error else {
                        Issue.record("Expected HTTP status error")
                        return
                    }
                    #expect(actual == status)
                }
            }
            #expect(attempts.withLock { $0 } == 1)
        }
    }

    @Test("Retries stop after three total attempts")
    func retryLimit() async {
        let attempts = Mutex(0)
        StubURLProtocol.handler = { request in
            attempts.withLock { $0 += 1 }
            return try makeResponse(request, status: 500)
        }
        let sut = APIManager(session: makeStubbedSession(), sleep: { _ in })
        await #expect(throws: APIError.self) {
            let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        }
        #expect(attempts.withLock { $0 } == 3)
    }

    @Test("Retry-After is honored; excessive waits return the server error")
    func respectsRetryAfter() async throws {
        for header in ["5", "Thu, 01 Jan 1970 00:00:05 GMT", "120"] {
            let attempts = Mutex(0)
            StubURLProtocol.handler = { request in
                let attempt = attempts.withLock { $0 += 1; return $0 }
                return try makeResponse(request, status: attempt == 1 ? 429 : 200, headers: ["Retry-After": header])
            }
            var delays: [TimeInterval] = []
            let sut = APIManager(session: makeStubbedSession(), now: { Date(timeIntervalSince1970: 0) }, sleep: { delays.append($0) })
            if header == "120" {
                await #expect(throws: APIError.self) {
                    let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
                }
                #expect(delays.isEmpty)
                #expect(attempts.withLock { $0 } == 1)
            } else {
                let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
                #expect(delays == [5])
            }
        }
    }

    @Test("Cancellation during backoff stops retries")
    func cancelsBackoff() async {
        let attempts = Mutex(0)
        StubURLProtocol.handler = { request in
            attempts.withLock { $0 += 1 }
            return try makeResponse(request, status: 503)
        }
        let (events, continuation) = AsyncStream<Void>.makeStream()
        defer { continuation.finish() }
        let sut = APIManager(session: makeStubbedSession(), sleep: { _ in
            continuation.yield(())
            try await Task.sleep(for: .seconds(30))
        })
        let request = Task { () throws -> [String: Int] in
            try await sut.fetch(.worldState(platform: .pc))
        }
        for await _ in events { break }
        request.cancel()
        await #expect(throws: CancellationError.self) {
            _ = try await request.value
        }
        #expect(attempts.withLock { $0 } == 1)
    }

    @Test("World state expires at 30 seconds; cache keys include the platform")
    func worldStateTTL() async throws {
        let attempts = Mutex(0)
        StubURLProtocol.handler = { request in
            attempts.withLock { $0 += 1 }
            return try makeResponse(request)
        }
        var now = Date(timeIntervalSince1970: 0)
        let sut = APIManager(session: makeStubbedSession(), now: { now })
        let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        now = now.addingTimeInterval(29)
        let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        #expect(attempts.withLock { $0 } == 1)
        let _: [String: Int] = try await sut.fetch(.worldState(platform: .ps4))
        #expect(attempts.withLock { $0 } == 2)
        now = now.addingTimeInterval(1)
        let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        #expect(attempts.withLock { $0 } == 3)
    }

    @Test("Catalog responses expire at one hour and cache clearing forces a request")
    func catalogTTLAndInvalidation() async throws {
        let attempts = Mutex(0)
        StubURLProtocol.handler = { request in
            attempts.withLock { $0 += 1 }
            return try makeResponse(request)
        }
        var now = Date(timeIntervalSince1970: 0)
        let sut = APIManager(session: makeStubbedSession(), now: { now })
        let _: [String: Int] = try await sut.fetch(.catalog(.items))
        now = now.addingTimeInterval(3_599)
        let _: [String: Int] = try await sut.fetch(.catalog(.items))
        #expect(attempts.withLock { $0 } == 1)
        now = now.addingTimeInterval(1)
        let _: [String: Int] = try await sut.fetch(.catalog(.items))
        #expect(attempts.withLock { $0 } == 2)
        sut.clearCache()
        let _: [String: Int] = try await sut.fetch(.catalog(.items))
        #expect(attempts.withLock { $0 } == 3)
    }

    @Test("Profile requests and no-store responses bypass the memory cache")
    func bypassesCache() async throws {
        for endpoint in [Endpoint.profile(playerId: "account"), .worldState(platform: .pc)] {
            let attempts = Mutex(0)
            StubURLProtocol.handler = { request in
                attempts.withLock { $0 += 1 }
                return try makeResponse(request, headers: request.url?.host == "api.warframe.com" ? [:] : ["Cache-Control": "no-store"])
            }
            let sut = APIManager(session: makeStubbedSession())
            let _: [String: Int] = try await sut.fetch(endpoint)
            let _: [String: Int] = try await sut.fetch(endpoint)
            #expect(attempts.withLock { $0 } == 2)
        }
    }

    @Test("Clearing during a retry prevents the old request from repopulating cache")
    func invalidatesInFlightResponse() async throws {
        let attempts = Mutex(0)
        StubURLProtocol.handler = { request in
            let attempt = attempts.withLock { $0 += 1; return $0 }
            return try makeResponse(request, status: attempt == 1 ? 503 : 200)
        }
        var clearCache: () -> Void = {}
        let sut = APIManager(session: makeStubbedSession(), sleep: { _ in clearCache() })
        clearCache = { sut.clearCache() }
        let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        let _: [String: Int] = try await sut.fetch(.worldState(platform: .pc))
        #expect(attempts.withLock { $0 } == 3)
    }

}

nonisolated private func makeResponse(
    _ request: URLRequest,
    status: Int = 200,
    body: String = "{\"value\":1}",
    headers: [String: String] = [:]
) throws -> (HTTPURLResponse, Data) {
    let url = try #require(request.url)
    let response = try #require(HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: headers))
    return (response, Data(body.utf8))
}
