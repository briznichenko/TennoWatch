//
//  APIManagerTests.swift
//  WarframeListenerTests
//

import Testing
import Foundation
@testable import WarframeListener

private final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

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
    @Test("A fractional-second ISO8601 date decodes to the same value a standard ISO8601 parse would produce")
    func decodesFractionalSecondISO8601Date() async throws {
        let dateString = "2026-09-15T12:30:45.123Z"
        StubURLProtocol.handler = { request in
            let json = Data("{\"date\":\"\(dateString)\"}".utf8)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
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
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        let sut = APIManager(session: makeStubbedSession())

        await #expect(throws: APIError.self) {
            let _: StubModel = try await sut.fetch(.worldState(platform: .pc))
        }
    }

    // TODO: - Test that the "+275760-09-13" sentinel string (the API's "no expiry" marker) decodes to Date.distantFuture
    // TODO: - Test that a malformed date string throws a DecodingError instead of crashing or silently defaulting
    // TODO: - Test that malformed/truncated JSON throws a DecodingError
}
