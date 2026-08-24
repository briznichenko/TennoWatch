//
//  ApiManager.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation
import Combine

enum Endpoint {
    case invasions

    private static let baseURL = URL(string: "https://api.warframestat.us/pc/")!

    var url: URL {
        switch self {
        case .invasions:
            Self.baseURL.appending(path: "invasions")
        }
    }
}

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
            guard let date = dateFormatter.date(from: string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
            }
            return date
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
