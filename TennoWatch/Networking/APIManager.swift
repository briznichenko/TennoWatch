//
//  ApiManager.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation
import Combine

enum APIError: Error {
    case invalidResponse
}

protocol ServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIManager: ServiceProtocol {
    // MARK: - Object Properties
    private let session: URLSession

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
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Functions
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await session.data(from: endpoint.url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == ResponseConstants.successStatusCode else {
            throw APIError.invalidResponse
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

private struct ResponseConstants {
    static let successStatusCode = 200
    static let unboundedDatePrefix = "+275760-09-13"
}
