//
//  Models.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var name: String = ""
    var brand: String = ""
    var avgMonthlyCars: Int = 10
    var monthlyGoal: Double = 10_000
}

struct Deal: Identifiable, Codable, Hashable {
    let id: UUID
    var customerName: String           // required
    var vehicle: String                // required (the car they bought)
    var dealNumber: String?            // optional
    var commission: Double             // required
    var date: Date

    init(id: UUID = UUID(),
         customerName: String,
         vehicle: String,
         dealNumber: String? = nil,
         commission: Double,
         date: Date = Date()) {
        self.id = id
        self.customerName = customerName
        self.vehicle = vehicle
        self.dealNumber = dealNumber
        self.commission = commission
        self.date = date
    }
}
