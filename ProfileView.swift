//
//  ProfileView.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileStore: ProfileStore

    var body: some View {
        ZStack {
            Color.AppBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Profile")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 8) {
                    Text("Name: \(profileStore.profile.name)")
                    Text("Brand: \(profileStore.profile.brand)")
                }
                .foregroundStyle(.white.opacity(0.9))

                Text("Login & account settings coming soon.")
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 8)

                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview("Profile") {
    ProfileView()
        .environmentObject(PreviewStores.profile)
        .environmentObject(PreviewStores.deals)
}

