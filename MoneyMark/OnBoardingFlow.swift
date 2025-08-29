//
//  OnBoardingFlow.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI

// ViewModel to carry data through steps
@MainActor
final class OnboardingVM: ObservableObject {
    @Published var name: String = ""
    @Published var brand: String = ""
    @Published var avgMonthlyCars: Int = 10
    @Published var monthlyGoal: Double = 10_000
}

// Entry point for onboarding
struct OnboardingStart: View {
    @StateObject private var vm = OnboardingVM()

    var body: some View {
        NavigationStack {
            OnboardingName()
                .environmentObject(vm)
        }
    }
}

// MARK: Step 1 — Name
struct OnboardingName: View {
    @EnvironmentObject var vm: OnboardingVM

    var body: some View {
        VStack(spacing: 24) {
            header("Your Name")

            fieldCard {
                TextField("Enter your name", text: $vm.name)
                    .textInputAutocapitalization(.words)
                    .tint(.yellow)
                    .foregroundStyle(.white)
            }

            Spacer()

            NavigationLink {
                OnboardingBrand().environmentObject(vm)
            } label: {
                Text("Continue").primaryButtonStyle(disabled: vm.name.trimmed().isEmpty)
            }
            .disabled(vm.name.trimmed().isEmpty)
        }
        .padding(20)
        .background(Color.AppBackground.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { Text("Setup").foregroundStyle(.white) } }
    }
}

// MARK: Step 2 — Brand
struct OnboardingBrand: View {
    @EnvironmentObject var vm: OnboardingVM

    var body: some View {
        VStack(spacing: 24) {
            header("Your Brand")

            fieldCard {
                TextField("e.g., Nissan, Toyota…", text: $vm.brand)
                    .textInputAutocapitalization(.words)
                    .tint(.yellow)
                    .foregroundStyle(.white)
            }

            Spacer()

            NavigationLink {
                OnboardingAvgCars().environmentObject(vm)
            } label: {
                Text("Continue").primaryButtonStyle(disabled: vm.brand.trimmed().isEmpty)
            }
            .disabled(vm.brand.trimmed().isEmpty)
        }
        .padding(20)
        .background(Color.AppBackground.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { Text("Setup").foregroundStyle(.white) } }
    }
}

// MARK: Step 3 — Avg Cars
struct OnboardingAvgCars: View {
    @EnvironmentObject var vm: OnboardingVM

    var body: some View {
        VStack(spacing: 24) {
            header("Avg Cars / Month")

            fieldCard {
                Stepper(value: $vm.avgMonthlyCars, in: 0...200) {
                    Text("\(vm.avgMonthlyCars) cars")
                        .foregroundStyle(.white)
                }
                .tint(.yellow)
            }

            Spacer()

            NavigationLink {
                OnboardingGoal().environmentObject(vm)
            } label: {
                Text("Continue").primaryButtonStyle()
            }
        }
        .padding(20)
        .background(Color.AppBackground.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { Text("Setup").foregroundStyle(.white) } }
    }
}

// MARK: Step 4 — Monthly Goal (Finish)
struct OnboardingGoal: View {
    @EnvironmentObject var vm: OnboardingVM
    @EnvironmentObject var profileStore: ProfileStore
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var goDashboard = false

    var body: some View {
        VStack(spacing: 24) {
            header("Monthly Goal")

            fieldCard {
                HStack {
                    Text("Goal").foregroundStyle(.white.opacity(0.85))
                    Spacer()
                    TextField("$10,000", value: $vm.monthlyGoal, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .tint(.yellow)
                        .foregroundStyle(.white)
                        .frame(width: 180)
                }
            }

            Spacer()

            Button {
                // Save profile, toggle the flag, then route to Dashboard
                profileStore.profile = UserProfile(
                    name: vm.name.trimmed(),
                    brand: vm.brand.trimmed(),
                    avgMonthlyCars: vm.avgMonthlyCars,
                    monthlyGoal: vm.monthlyGoal
                )
                hasOnboarded = true
                goDashboard = true
            } label: {
                Text("Finish").primaryButtonStyle()
            }
            .navigationDestination(isPresented: $goDashboard) {
                Dashboard()
            }
        }
        .padding(20)
        .background(Color.AppBackground.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { Text("Setup").foregroundStyle(.white) } }
    }
}

// MARK: helpers
private func header(_ title: String) -> some View {
    Text(title)
        .font(.largeTitle.bold())
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
}

private func fieldCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        content()
    }
    .padding(18)
    .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.05)))
    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12)))
}

private extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private extension Text {
    func primaryButtonStyle(disabled: Bool = false) -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(disabled ? Color.yellow.opacity(0.4) : .yellow)
            .foregroundStyle(.black)
            .clipShape(Capsule())
    }
    #Preview {
        OnboardingGoal()
            .environmentObject(ProfileStore())  // 👈 add mock store here
            .environmentObject(DealStore())     // 👈 and here
    }
}
