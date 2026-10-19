//
//  PrimeReleaseOrder.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/19/26.
//

import Foundation

struct PrimeReleaseOrder: Decodable {
    struct Frame: Decodable, Identifiable {
        let name: String
        let releaseDate: Date
        let isPrime: Bool

        var id: String { name }
    }

    let updatedAt: Date
    let frames: [Frame]

    func candidates(at date: Date) -> [Frame] {
        let releasedFrames = frames.filter { $0.releaseDate <= date }
        let primeNames = Set(releasedFrames.filter(\.isPrime).map(\.name))
        return releasedFrames
            .filter { !$0.isPrime && !primeNames.contains($0.name + " Prime") }
            .sorted {
                $0.releaseDate == $1.releaseDate ? $0.name < $1.name : $0.releaseDate < $1.releaseDate
            }
    }

    static let bundled: PrimeReleaseOrder? = {
        guard let url = Bundle.main.url(forResource: "primeReleaseOrder", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(PrimeReleaseOrder.self, from: data)
    }()
}
