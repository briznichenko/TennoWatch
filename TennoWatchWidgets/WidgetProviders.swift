//
//  WidgetProviders.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/03/26.
//

import Foundation
import WidgetKit

struct BaroEntry: TimelineEntry {
    let date: Date
    let snapshot: BaroSnapshot?
    let isStale: Bool

    static var preview: Self {
        .init(date: .now, snapshot: .init(
            activation: .now.addingTimeInterval(86_400), expiry: .now.addingTimeInterval(259_200),
            location: "Larunda Relay (Mercury)", updatedAt: .now
        ), isStale: false)
    }
}

struct BaroProvider: TimelineProvider {
    func placeholder(in context: Context) -> BaroEntry { .preview }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (BaroEntry) -> Void) {
        if context.isPreview {
            completion(.preview)
        } else {
            let snapshot = WidgetSnapshotStore().baro()
            completion(.init(date: .now, snapshot: snapshot, isStale: isStale(snapshot)))
        }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<BaroEntry>) -> Void) {
        Task {
            let store = WidgetSnapshotStore()
            var snapshot = store.baro()
            if isStale(snapshot) {
                do {
                    snapshot = try await fetchBaro()
                    if let snapshot { store.saveBaro(snapshot, requestReload: false) }
                } catch {
                    snapshot = store.baro()
                }
            }
            let now = Date.now
            var dates = [now]
            if let activation = snapshot?.activation, activation > now { dates.append(activation) }
            if let expiry = snapshot?.expiry, expiry > now { dates.append(expiry) }
            let entries = dates.sorted().map {
                BaroEntry(date: $0, snapshot: snapshot, isStale: isStale(snapshot, at: $0))
            }
            completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3_600))))
        }
    }

    private func isStale(_ snapshot: BaroSnapshot?, at date: Date = .now) -> Bool {
        guard let snapshot else { return true }
        return date.timeIntervalSince(snapshot.updatedAt) >= 3_600 || (snapshot.expiry ?? .distantPast) <= date
    }

    private func fetchBaro() async throws -> BaroSnapshot {
        guard let url = URL(string: "https://api.warframestat.us/pc/voidTrader") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let date = fractional.date(from: text) ?? ISO8601DateFormatter().date(from: text) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid schedule date")
            }
            return date
        }
        let trader = try decoder.decode(TraderResponse.self, from: data)
        guard let activation = trader.activation, let expiry = trader.expiry, expiry > activation else {
            throw URLError(.cannotParseResponse)
        }
        return .init(activation: activation, expiry: expiry, location: trader.location, updatedAt: .now)
    }

    private struct TraderResponse: Decodable {
        let activation: Date?
        let expiry: Date?
        let location: String
    }
}

struct MasteryEntry: TimelineEntry {
    let date: Date
    let snapshot: MasterySnapshot?

    static var preview: Self {
        .init(date: .now, snapshot: .init(
            accountID: "preview", name: "Tenno", playerRank: 12, earnedXP: 385_000, updatedAt: .now
        ))
    }
}

struct MasteryProvider: TimelineProvider {
    func placeholder(in context: Context) -> MasteryEntry { .preview }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (MasteryEntry) -> Void) {
        completion(context.isPreview ? .preview : .init(date: .now, snapshot: WidgetSnapshotStore().mastery()))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<MasteryEntry>) -> Void) {
        let entry = MasteryEntry(date: .now, snapshot: WidgetSnapshotStore().mastery())
        completion(Timeline(entries: [entry], policy: .after(entry.date.addingTimeInterval(3_600))))
    }
}
