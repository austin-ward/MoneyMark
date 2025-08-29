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
                    Dashboard()
                } else {
                    ContentView()
                }
            }
            // 👇 Inject ONCE here
            .environmentObject(profileStore)
            .environmentObject(dealStore)
        }
    }
    #Preview {
        OnboardingGoal()
            .environmentObject(ProfileStore())  // 👈 add mock store here
            .environmentObject(DealStore())     // 👈 and here
    }
}
