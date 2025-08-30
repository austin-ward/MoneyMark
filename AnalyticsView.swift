//
//  AnalyticsView.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var dealStore: DealStore
    @Environment(\.colorScheme) private var scheme

    enum Range: String, CaseIterable, Identifiable {
        case week = "Week", month = "Month", quarter = "Quarter", year = "Year"
        var id: String { rawValue }
    }

    struct Bin: Identifiable, Hashable {
        let id = UUID()
        let label: String
        let start: Date
        let end: Date
        var commissionTotal: Double = 0
        var units: Int = 0
    }

    @State private var selected: Range = .week

    // MARK: - Derived data
    private var bins: [Bin] {
        bins(for: selected, deals: dealStore.deals)
    }
    private var totalCommission: Double {
        bins.reduce(0) { $0 + $1.commissionTotal }
    }
    private var totalUnits: Int {
        bins.reduce(0) { $0 + $1.units }
    }

    var body: some View {
        ZStack {
            Color.AppBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Analytics")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 8)

                    // Range picker
                    Picker("Range", selection: $selected) {
                        ForEach(Range.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.trailing, 6)
                    .tint(.yellow)

                    // Totals cards
                    HStack(spacing: 12) {
                        StatCard(title: "Commission", value: totalCommission.formatted(.currency(code: "USD")))
                        StatCard(title: "Units", value: "\(totalUnits)")
                    }

                    // Commission chart
                    GroupBoxLabel(title: "Commission by Period") {
                        Chart(bins) { bin in
                            BarMark(
                                x: .value("Period", bin.label),
                                y: .value("Commission", bin.commissionTotal)
                            )
                            .foregroundStyle(.yellow)
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 220)
                    }

                    // Units chart
                    GroupBoxLabel(title: "Units by Period") {
                        Chart(bins) { bin in
                            BarMark(
                                x: .value("Period", bin.label),
                                y: .value("Units", bin.units)
                            )
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 220)
                    }

                    Spacer(minLength: 12)
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Layout helpers

private struct StatCard: View {
    var title: String
    var value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.yellow)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.12)))
    }
}

private struct GroupBoxLabel<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
            content
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.04)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08)))
        }
    }
}

// MARK: - Binning logic
extension AnalyticsView {
    func bins(for range: Range, deals: [Deal]) -> [Bin] {
        let cal = Calendar.current
        let now = Date()

        switch range {
        case .week:
            // 7 daily bins (oldest → newest)
            let start = cal.startOfDay(for: now.addingTimeInterval(-6 * 24 * 3600))
            return (0..<7).map { i in
                let s = cal.date(byAdding: .day, value: i, to: start)!
                let e = cal.date(byAdding: .day, value: 1, to: s)!
                let label = s.formatted(.dateTime.day())
                return makeBin(label: label, start: s, end: e, from: deals)
            }

        case .month:
            // Current month grouped by week-of-month (4–5 bars)
            guard
                let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)),
                let startOfNext  = cal.date(byAdding: .month, value: 1, to: startOfMonth)
            else { return [] }

            var result: [Bin] = []
            var cursor = startOfMonth
            while cursor < startOfNext {
                if let weekInterval = cal.dateInterval(of: .weekOfMonth, for: cursor) {
                    let s = max(weekInterval.start, startOfMonth)
                    let e = min(weekInterval.end, startOfNext)
                    let weekIndex = cal.component(.weekOfMonth, from: s)
                    result.append(makeBin(label: "W\(weekIndex)", start: s, end: e, from: deals))
                    cursor = e
                } else { break }
            }
            return result

        case .quarter:
            // Current quarter grouped by month (3 bars)
            let comps = cal.dateComponents([.year, .month], from: now)
            guard let month = comps.month, let year = comps.year else { return [] }
            let qIndex = (month - 1) / 3
            let startMonth = qIndex * 3 + 1
            guard let start = cal.date(from: DateComponents(year: year, month: startMonth)) else { return [] }

            return (0..<3).map { i in
                let s = cal.date(byAdding: .month, value: i, to: start)!
                let e = cal.date(byAdding: .month, value: 1, to: s)!
                let label = s.formatted(.dateTime.month(.abbreviated))
                return makeBin(label: label, start: s, end: e, from: deals)
            }

        case .year:
            // Current year grouped by month (12 bars)
            guard let start = cal.date(from: cal.dateComponents([.year], from: now)) else { return [] }

            return (0..<12).map { i in
                let s = cal.date(byAdding: .month, value: i, to: start)!
                let e = cal.date(byAdding: .month, value: 1, to: s)!
                let label = s.formatted(.dateTime.month(.abbreviated))
                return makeBin(label: label, start: s, end: e, from: deals)
            }
        }
    }

    private func makeBin(label: String, start: Date, end: Date, from deals: [Deal]) -> Bin {
        let subset = deals.filter { $0.date >= start && $0.date < end }
        let total = subset.reduce(0) { $0 + $1.commission }
        var bin = Bin(label: label, start: start, end: end)
        bin.commissionTotal = total
        bin.units = subset.count
        return bin
    }
}


#Preview("Analytics") {
    AnalyticsView()
        .environmentObject(PreviewStores.profile)
        .environmentObject(PreviewStores.deals)
}

