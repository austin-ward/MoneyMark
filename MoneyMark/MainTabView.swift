//
//  MainTabView.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Dashboard()
                .tabItem { Label("Home", systemImage: "house.fill") }

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }

            PastDealsView()                       // <- this type must exist in your target
                .tabItem { Label("Past Deals", systemImage: "list.bullet.rectangle") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(.yellow)
    }
}
#if DEBUG
// TEMP diagnostic to prove the type is missing from the target.
// If this makes the error go away, your separate PastDealsView.swift isn't in the build.
struct PastDealsView: View {
    var body: some View { Text("TEMP Past Deals") }
}
#endif


