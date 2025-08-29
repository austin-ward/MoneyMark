//
//  Dashboard.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

// Dashboard.swift
import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var profileStore: ProfileStore
    @EnvironmentObject var dealStore: DealStore
    @State private var showingAdd = false

    private var last7: [Date] {
        (0..<7).reversed().map { Calendar.current.startOfDay(for: Date().addingTimeInterval(Double(-$0) * 24 * 3600)) }
    }
    private var progress: Double {
        let goal = max(profileStore.profile.monthlyGoal, 0.0001)
        return min(dealStore.monthToDateTotal() / goal, 1.0)
    }

    var body: some View {
        ZStack {
            Color.AppBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("MoneyMark")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                // date + 7-day chips
                VStack(alignment: .leading, spacing: 8) {
                    Text(Date(), format: .dateTime.weekday(.wide).month().day())
                        .font(.headline).foregroundStyle(.white)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(last7, id: \.self) { day in
                                DayBubble(day: day, isActive: dealStore.hasDeal(on: day))
                            }
                        }
                        .padding(8)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                        .overlay(Capsule().stroke(.white.opacity(0.12)))
                    }
                    Text("Weekly Trend")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    let count = dealStore.deals.filter {
                        $0.date >= Calendar.current.startOfDay(for: Date().addingTimeInterval(-6*24*3600))
                    }.count
                    Text("You’ve sold \(count) \(count == 1 ? "car" : "cars") in the past 7 days 🔥🤩")
                        .font(.footnote).foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                // monthly goal card
                VStack(spacing: 14) {
                    Text(profileStore.profile.monthlyGoal, format: .currency(code: "USD"))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.yellow)
                        .frame(maxWidth: .infinity)

                    ProgressPill(progress: progress, label: "\(Int(round(progress*100)))%")

                    RoundedGroup(title: "Last 5 Sold") {
                        VStack(spacing: 8) {
                            RowHeader()
                            ForEach(dealStore.lastFive()) { deal in
                                RowItem(name: deal.customerName, commission: deal.commission)
                            }
                            if dealStore.lastFive().isEmpty {
                                Text("No recent sales").foregroundStyle(.white.opacity(0.7)).padding(.vertical, 6)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    HStack {
                        Text("Last 7 Days").font(.headline).foregroundStyle(.white)
                        Spacer()
                        Text(dealStore.totalLast7Days(), format: .currency(code: "USD"))
                            .font(.headline.weight(.semibold)).foregroundStyle(.white)
                    }
                    .padding(.top, 6)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.12)))
                .padding(.horizontal, 20)
                .padding(.top, 6)

                Button { showingAdd = true } label: {
                    Text("ADD DEAL")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color.black.opacity(0.6))
                            .shadow(color: .black.opacity(0.8), radius: 14, x: 0, y: 8))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.AppAccent))
                        .foregroundStyle(.yellow)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 8)
                .sheet(isPresented: $showingAdd) {
                    AddDealSheet().environmentObject(dealStore)
                }

                Spacer(minLength: 8)
            }
        }
    }
}

// Subviews used above:
private struct DayBubble: View {
    var day: Date
    var isActive: Bool
    var body: some View {
        let n = Calendar.current.component(.day, from: day)
        Text("\(n)")
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .padding(.vertical, 10).padding(.horizontal, 14)
            .background(Circle().fill(isActive ? Color.appGold : Color.white.opacity(0.1)))
            .foregroundStyle(isActive ? .black : .white)
            .overlay(Circle().stroke(.white.opacity(0.15)))
    }
}

struct ProgressPill: View {
    var progress: Double       // 0...n (we will clamp)
    var label: String

    var body: some View {
        let p = min(max(progress, 0), 1)   // 👈 hard clamp here

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .frame(height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.yellow, lineWidth: 1)
                )

            GeometryReader { geo in
                // inner fill respects the clamp
                RoundedRectangle(cornerRadius: 14)
                    .fill(.yellow)
                    .frame(width: max(8, geo.size.width * p), height: 28)
                    .padding(.vertical, 4)
                    .padding(.leading, 4)
            }
            .frame(height: 36)

            // label stays centered, even when p < 0.1 or > 1
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 36)
    }
}


private struct RoundedGroup<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.subheadline.weight(.bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.top, 6)
            content.padding(.horizontal, 10).padding(.bottom, 10)
        }
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.yellow, lineWidth: 1))
    }
}

private struct RowHeader: View {
    var body: some View {
        HStack {
            Text("Name").foregroundStyle(.white.opacity(0.9))
            Spacer()
            Text("Commission").foregroundStyle(.white.opacity(0.9))
        }
        .font(.footnote.weight(.semibold)).padding(.vertical, 4)
    }
}

private struct RowItem: View {
    var name: String; var commission: Double
    var body: some View {
        HStack {
            Text(name).foregroundStyle(.white); Spacer()
            Text(commission, format: .currency(code: "USD")).foregroundStyle(.yellow)
        }
        .font(.subheadline).padding(.vertical, 2)
    }
}

#Preview {
    Dashboard()
        .environmentObject(ProfileStore())
        .environmentObject(DealStore())
}
