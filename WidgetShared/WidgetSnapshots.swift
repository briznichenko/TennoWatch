//
//  WidgetSnapshots.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/03/26.
//

import Foundation
import WidgetKit

struct BaroSnapshot: Codable, Sendable {
    let activation: Date?
    let expiry: Date?
    let location: String
    let updatedAt: Date

    func phase(at date: Date) -> Phase {
        guard let activation, let expiry, expiry > activation else { return .unavailable }
        if date < activation { return .upcoming }
        return date < expiry ? .visiting : .departed
    }

    enum Phase: Sendable {
        case upcoming, visiting, departed, unavailable
    }
}

struct MasterySnapshot: Codable, Sendable {
    let accountID: String
    let name: String
    let playerRank: Int?
    let earnedXP: Int
    let obtainableMasteryMax: Int?
    let updatedAt: Date

    var progress: MasteryRankProgress {
        .calculate(forXP: earnedXP, playerRank: playerRank)
    }
}

struct WidgetSnapshotStore: Sendable {
    static let groupID = "group.com.briznichenko.TennoWatch"
    static let baroKind = "TennoWatch.Baro"
    static let masteryKind = "TennoWatch.MasteryRank"

    private var defaults: UserDefaults? { UserDefaults(suiteName: Self.groupID) }

    func baro() -> BaroSnapshot? { read(BaroSnapshot.self, key: "baro") }

    func mastery() -> MasterySnapshot? {
        guard let accountID = defaults?.string(forKey: "selectedAccountID") else { return nil }
        return read([MasterySnapshot].self, key: "mastery")?.first { $0.accountID == accountID }
    }

    func saveBaro(_ snapshot: BaroSnapshot, requestReload: Bool = true) {
        save(snapshot, key: "baro", kind: Self.baroKind, requestReload: requestReload)
    }

    func saveMastery(_ snapshots: [MasterySnapshot]) {
        save(snapshots, key: "mastery", kind: Self.masteryKind)
    }

    func selectAccount(_ accountID: String?) {
        guard defaults?.string(forKey: "selectedAccountID") != accountID else { return }
        defaults?.set(accountID, forKey: "selectedAccountID")
        WidgetCenter.shared.reloadTimelines(ofKind: Self.masteryKind)
    }

    func clear() {
        for key in ["baro", "mastery", "selectedAccountID"] { defaults?.removeObject(forKey: key) }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func read<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults?.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, key: String, kind: String, requestReload: Bool = true) {
        guard let data = try? JSONEncoder().encode(value), defaults?.data(forKey: key) != data else { return }
        defaults?.set(data, forKey: key)
        if requestReload { WidgetCenter.shared.reloadTimelines(ofKind: kind) }
    }
}
