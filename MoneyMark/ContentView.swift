//
//  ContentView.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI

struct ContentView: View {
    
        @EnvironmentObject var profileStore: ProfileStore
        @EnvironmentObject var dealStore: DealStore

    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.AppBackground.ignoresSafeArea()

                VStack {
                    Spacer(minLength: 120)

                    Image("dashboardex")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 340)
                        .padding(.bottom, 20)

                    // Logo + Title
                    HStack(spacing: 12) {
                        AppIcon()
                        Text("MoneyMark")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    // Tagline
                    Text("Sales Commission Tracker")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 8)

                    // One-liner
                    (
                        Text("No spreadsheets. No math.\nJust your ")
                            .foregroundStyle(.white.opacity(0.9))
                        +
                        Text("money.")
                            .foregroundStyle(.yellow)
                    )
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                    // Promo card + CTA
                    VStack(spacing: 16) {
                        Text("Get started today.")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Track your commission,\nhit your goals,\nand stay motivated.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))

                        // Navigate to onboarding flow
                        NavigationLink {
                            OnboardingStart()  // <<-- here
                        } label: {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .background(.yellow)
                                .foregroundStyle(.black)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.appAccent, lineWidth: 1)
                            .shadow(radius: 8)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    Spacer()
                }
                .padding(.bottom, 24)
            }
        }
    }
}

// Small rounded app icon with a yellow "$"
private struct AppIcon: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.AppAccent.opacity(0.06))
            .frame(width: 44, height: 44)
            .overlay(
                Text("$")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.yellow)
            )
    }
    
    
    #Preview {
        OnboardingGoal()
            .environmentObject(ProfileStore())  // 👈 add mock store here
            .environmentObject(DealStore())     // 👈 and here
    }
}
