//
//  ApiManager.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation
import Combine

enum APIError: Error {
    case invalidResponse
}

final class APIManager {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = dateFormatter.date(from: string) {
                return date
            }
            // Some "never expires" fields (e.g. arbitration) use JavaScript's maximum
            // Date value as a sentinel, which ISO8601DateFormatter can't parse (it uses
            // an extended 6-digit year with a leading '+').
            if string.hasPrefix("+275760-09-13") {
                return .distantFuture
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        self.decoder = decoder
    }

    func fetch<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: endpoint.url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
