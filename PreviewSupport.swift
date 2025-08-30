//
//  PreviewSupport.swift
//  MoneyMark

//  To allow for previews on each file.

//  Created by Austin on 8/29/25.
//

import SwiftUI

/// Put preview-only stores on the main actor so we can init/mutate safely.
@MainActor
enum PreviewStores {
    static let profile: ProfileStore = {
        let s = ProfileStore()
        s.profile.name = "Austin"
        s.profile.brand = "Nissan"
        s.profile.monthlyGoal = 10_000
        return s
    }()

    static let deals: DealStore = {
        let s = DealStore()
        s.deals = [
            Deal(customerName: "Steve",      vehicle: "Altima",  dealNumber: "1123", commission: 40_000, date: .now.addingTimeInterval(-2*86_400)),
            Deal(customerName: "Sam",        vehicle: "Rogue",   dealNumber: "1125", commission: 1_000,  date: .now.addingTimeInterval(-1*86_400)),
            Deal(customerName: "Mr Crusty",  vehicle: "Sentra",  dealNumber: "1127", commission: 300,    date: .now),
        ]
        return s
    }()
}

