//
//  APIManager.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case httpStatus(Int)
}

protocol ServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func clearCache()
}

extension ServiceProtocol {
    func clearCache() {}
}

final class APIManager: ServiceProtocol {
    // MARK: - Object Properties
    private let session: URLSession
    private let now: () -> Date
    private let sleep: (TimeInterval) async throws -> Void
    private var cache: [URL: CachedResponse] = [:]
    private var cacheRevision = 0

    private struct CachedResponse {
        let data: Data
        let expiresAt: Date
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = dateFormatter.date(from: string) {
                return date
            }
            if string.hasPrefix(ResponseConstants.unboundedDatePrefix) {
                return .distantFuture
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        return decoder
    }()

    // MARK: - Init
    init(
        session: URLSession = APIManager.makeSession(),
        now: @escaping () -> Date = Date.init,
        sleep: @escaping (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(for: .seconds(seconds))
        }
    ) {
        self.session = session
        self.now = now
        self.sleep = sleep
    }

    // MARK: - Functions
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try Task.checkCancellation()
        let url = try endpoint.url
        if let cached = cache[url], cached.expiresAt > now() {
            return try decoder.decode(T.self, from: cached.data)
        }
        cache[url] = nil
        let revision = cacheRevision
        var retry = 0
        while true {
            try Task.checkCancellation()
            let data: Data
            let response: URLResponse
            do {
                (data, response) = try await session.data(for: URLRequest(
                    url: url, cachePolicy: .reloadIgnoringLocalCacheData
                ))
            } catch {
                try Task.checkCancellation()
                guard retry < ResponseConstants.maximumRetries, Self.isTransient(error) else { throw error }
                try await sleep(Self.backoff(retry: retry))
                retry += 1
                continue
            }
            try Task.checkCancellation()
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200..<300).contains(httpResponse.statusCode) else {
                let error = APIError.httpStatus(httpResponse.statusCode)
                guard retry < ResponseConstants.maximumRetries,
                      ResponseConstants.retryableStatusCodes.contains(httpResponse.statusCode) else { throw error }
                let delay = retryDelay(for: httpResponse, retry: retry)
                guard delay <= ResponseConstants.maximumRetryDelay else { throw error }
                try await sleep(delay)
                retry += 1
                continue
            }
            let value = try decoder.decode(T.self, from: data)
            try Task.checkCancellation()
            if endpoint.cacheTTL > 0, revision == cacheRevision,
               !Self.disallowsCaching(httpResponse) {
                cache[url] = CachedResponse(data: data, expiresAt: now().addingTimeInterval(endpoint.cacheTTL))
            }
            return value
        }
    }

    func clearCache() {
        cacheRevision += 1
        cache.removeAll()
    }

    private static func isTransient(_ error: Error) -> Bool {
        guard let error = error as? URLError else { return false }
        switch error.code {
        case .timedOut, .networkConnectionLost, .cannotConnectToHost, .dnsLookupFailed, .cannotFindHost:
            return true
        default:
            return false
        }
    }

    private static func backoff(retry: Int) -> TimeInterval {
        pow(2, Double(retry)) + Double.random(in: 0...0.25)
    }

    private func retryDelay(for response: HTTPURLResponse, retry: Int) -> TimeInterval {
        let backoff = Self.backoff(retry: retry)
        guard let value = response.value(forHTTPHeaderField: "Retry-After") else { return backoff }
        if let seconds = TimeInterval(value), seconds.isFinite, seconds >= 0 {
            return max(backoff, seconds)
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        guard let date = formatter.date(from: value) else { return backoff }
        return max(backoff, date.timeIntervalSince(now()))
    }

    private static func disallowsCaching(_ response: HTTPURLResponse) -> Bool {
        let directives = response.value(forHTTPHeaderField: "Cache-Control")?.lowercased() ?? ""
        return directives.contains("no-store") || directives.contains("no-cache")
    }
}

private struct ResponseConstants {
    static let maximumRetries = 2
    static let maximumRetryDelay: TimeInterval = 30
    static let retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    static let unboundedDatePrefix = "+275760-09-13"
}
