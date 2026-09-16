//
//  APIManagerTests.swift
//  TennoWatchTests
//

import Testing
import Foundation
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

    @Test("A non-200 response throws APIError.invalidResponse")
    func nonSuccessStatusThrowsInvalidResponse() async {
        StubURLProtocol.handler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
            else {
                fatalError("Failed to construct stub response")
            }
            return (response, Data())
        }
        let sut = APIManager(session: makeStubbedSession())

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
}
