//
//  Stores.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet { save() }
    }
    private let filename = "user_profile.json"

    init() {
        self.profile = Persistence.loadJSON(UserProfile.self, from: filename, default: UserProfile())
    }

    private func save() {
        try? Persistence.saveJSON(profile, to: filename)
    }

    // helpers
    func resetToDefaults() { profile = UserProfile() }
}

@MainActor
final class DealStore: ObservableObject {
    @Published var deals: [Deal] {
        didSet { save() }
    }
    private let filename = "deals.json"

    init() {
        self.deals = Persistence.loadJSON([Deal].self, from: filename, default: [])
        // keep newest first for convenience
        self.deals.sort { $0.date > $1.date }
    }

    private func save() {
        try? Persistence.saveJSON(deals, to: filename)
    }

    // writes
    func addDeal(_ deal: Deal) {
        deals.append(deal)
        deals.sort { $0.date > $1.date }
    }

    // reads / computed
    func lastFive() -> [Deal] {
        Array(deals.prefix(5))
    }

    func totalLast7Days() -> Double {
        let start = Calendar.current.startOfDay(for: Date().addingTimeInterval(-6 * 24 * 3600))
        return deals.filter { $0.date >= start && $0.date <= Date() }
            .reduce(0) { $0 + $1.commission }
    }

    func monthToDateTotal() -> Double {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        return deals.filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.commission }
    }

    func hasDeal(on day: Date) -> Bool {
        deals.contains { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    func wipeAll() { deals = [] }
}
