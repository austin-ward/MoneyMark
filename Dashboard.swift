//  Dashboard.swift
//  MoneyMark

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var profileStore: ProfileStore
    @EnvironmentObject var dealStore: DealStore
    @State private var showingAdd = false

    // MARK: - Date helpers / formatters
    private var last7: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).compactMap { cal.date(byAdding: .day, value: -6 + $0, to: today) }
    }
    private let headerFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d" // e.g. Friday, Aug 29
        return df
    }()

    // MARK: - Derived metrics
    private var monthlyGoal: Double { max(0, profileStore.profile.monthlyGoal) }
    private var monthToDate: Double { dealStore.monthToDateTotal() }
    private var progress: Double {
        guard monthlyGoal > 0 else { return 0 }
        return min(monthToDate / monthlyGoal, 1.0)
    }
    private var last7Count: Int {
        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: Date()))!
        return dealStore.deals.filter { $0.date >= start }.count
    }
    private var last7Total: Double {
        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: Date()))!
        return dealStore.deals.filter { $0.date >= start }.reduce(0) { $0 + $1.commission }
    }
    private var last5Deals: [Deal] {
        Array(dealStore.deals.sorted { $0.date > $1.date }.prefix(5))
    }
    private var currencyCode: String { Locale.current.currency?.identifier ?? "USD" }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.AppBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    titleHeader
                    dateStrip
                    weeklyTrend
                    goalCard
                    addDealButton
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder private var titleHeader: some View {
        Text("MoneyMark")
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 4)
    }

    @ViewBuilder private var dateStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(headerFormatter.string(from: Date()))
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(last7, id: \.self) { day in
                        DayBubble(day: day, isActive: dealStore.hasDeal(on: day))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .background(Capsule().fill(Color.white.opacity(0.06)))
            .overlay(Capsule().stroke(Color.white.opacity(0.12)))
        }
    }

    @ViewBuilder private var weeklyTrend: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Weekly Trend")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Text("You’ve sold \(last7Count) \(last7Count == 1 ? "car" : "cars") in the past 7 days 🔥")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    @ViewBuilder private var goalCard: some View {
        VStack(spacing: 16) {
            Text("Monthly Goal")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text(monthlyGoal, format: .currency(code: currencyCode))
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.appGold)

            ProgressPill(progress: progress, label: "\(Int(progress * 100))%")

            // Last 5 Sold
            VStack(spacing: 12) {
                Text("Last 5 Sold")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                DealsList(deals: last5Deals, currencyCode: currencyCode)
            }

            // Last 7 Days total
            HStack {
                Text("Last 7 Days")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(last7Total, format: .currency(code: currencyCode))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 6)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 28).fill(Color.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.12)))
    }

    @ViewBuilder private var addDealButton: some View {
        Button {
            showingAdd = true
        } label: {
            Text("ADD DEAL")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.yellow)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.clear))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appGold, lineWidth: 2))
        }
        .sheet(isPresented: $showingAdd) {
            AddDealSheet().environmentObject(dealStore)
        }
    }
}

// MARK: - Components

private struct DealsList: View {
    let deals: [Deal]
    let currencyCode: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Name").foregroundStyle(.white.opacity(0.9))
                Spacer()
                Text("Commission").foregroundStyle(.white.opacity(0.9))
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider().background(Color.white.opacity(0.12))

            ForEach(deals) { deal in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deal.customerName).foregroundStyle(.white)
                        Text(deal.vehicle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                    Text(deal.commission, format: .currency(code: currencyCode))
                        .foregroundStyle(Color.appGold)
                }
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                Divider().background(Color.white.opacity(0.08))
            }
        }
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.appGold.opacity(0.9), lineWidth: 1))
    }
}

private struct DayBubble: View {
    var day: Date
    var isActive: Bool

    var body: some View {
        let n = Calendar.current.component(.day, from: day)
        Text("\(n)")
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .frame(width: 44, height: 44)
            .background(Circle().fill(isActive ? Color.appGold : Color.white.opacity(0.10)))
            .foregroundStyle(isActive ? .black : .white)
            .overlay(Circle().stroke(.white.opacity(0.15)))
    }
}

struct ProgressPill: View {
    var progress: Double
    var label: String

    private let outerR: CGFloat = 18
    private let inset: CGFloat = 4
    private let height: CGFloat = 36

    var body: some View {
        let p = min(max(progress, 0), 1) // clamp 0...1

        ZStack {
            RoundedRectangle(cornerRadius: outerR)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: outerR).stroke(.yellow, lineWidth: 1))

            GeometryReader { geo in
                let available = geo.size.width - inset * 2
                RoundedRectangle(cornerRadius: outerR - inset)
                    .fill(.yellow)
                    .frame(width: max(8, available * p), height: height - inset * 2)
                    .position(x: (available * p) / 2 + inset, y: geo.size.height / 2)
            }

            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.black)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: outerR))
    }
}

// MARK: - Preview
#Preview("Dashboard") {
    Dashboard()
        .environmentObject(PreviewStores.profile)
        .environmentObject(PreviewStores.deals)
}
