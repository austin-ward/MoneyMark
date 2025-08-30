//
//  MainTabView.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI

struct MainTabView: View {
    // App data
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var dealStore: DealStore

    // Gate the tabs until the user finishes onboarding
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    // Helpful for Xcode Previews only (lets us force-show the tabs)
    var forceTabsForPreview: Bool = false

    private enum Tab: Hashable { case home, analytics, past, profile }
    @State private var selection: Tab = .home

    var body: some View {
        if forceTabsForPreview || hasOnboarded {
            TabView(selection: $selection) {

                // 1) Dashboard (Home)
                Dashboard()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.home)

                // 2) Analytics
                AnalyticsView()
                    .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
                    .tag(Tab.analytics)

                // 3) Past Deals
                PastDealsView()
                    .tabItem { Label("Past Deals", systemImage: "list.bullet.rectangle") }
                    .tag(Tab.past)

                // 4) Profile
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                    .tag(Tab.profile)
            }
            // Yellow for the selected tab (unselected color comes from your app appearance)
            .tint(.yellow)
        } else {
            // Marketing / welcome screen -> pushes into the onboarding flow
            ContentView()
                .environmentObject(profileStore) // forward explicitly, keeps previews happy
                .environmentObject(dealStore)
        }
    }
}

#Preview("Main tabs") {
    MainTabView(forceTabsForPreview: true)
        .environmentObject(PreviewStores.profile)
        .environmentObject(PreviewStores.deals)
}
