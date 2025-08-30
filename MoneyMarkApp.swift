import SwiftUI
import UIKit

@main
struct MoneyMarkApp: App {
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var dealStore = DealStore()

    init() { Self.resetTabBarToTransparent() }

    static func resetTabBarToTransparent() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .clear
        appearance.shadowColor = nil

        let item = UITabBarItemAppearance()
        item.normal.iconColor = .white
        item.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        item.selected.iconColor = .systemYellow
        item.selected.titleTextAttributes = [.foregroundColor: UIColor.systemYellow]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = true
        tabBar.unselectedItemTintColor = .white
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(profileStore)
                .environmentObject(dealStore)
        }
    }
}

