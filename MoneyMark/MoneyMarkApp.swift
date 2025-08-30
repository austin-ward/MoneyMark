// MoneyMarkApp.swift
import SwiftUI

@main
struct MoneyMarkApp: App {
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var dealStore = DealStore()
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if hasOnboarded {
                    MainTabView()       // <— was Dashboard()
                } else {
                    ContentView()       // landing → onboarding
                }
            }
            .environmentObject(profileStore)
            .environmentObject(dealStore)
        }
    }
}
