//
//  AddDealSheet.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI

struct AddDealSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dealStore: DealStore

    @State private var customerName: String = ""
    @State private var vehicle: String = ""
    @State private var dealNumber: String = ""
    @State private var commissionText: String = ""
    @State private var date: Date = Date()

    private var isValid: Bool {
        guard !customerName.trimmed().isEmpty else { return false }
        guard !vehicle.trimmed().isEmpty else { return false }
        let cleaned = commissionText.replacingOccurrences(of: ",", with: "")
        return Double(cleaned) != nil && (Double(cleaned) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Required") {
                    TextField("Customer Name", text: $customerName)
                    TextField("Vehicle (e.g., 2024 Rogue SV)", text: $vehicle)
                    TextField("Commission (USD)", text: $commissionText)
                        .keyboardType(.decimalPad)
                }
                Section("Optional") {
                    TextField("Deal Number", text: $dealNumber)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Deal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let value = Double(commissionText.replacingOccurrences(of: ",", with: "")) ?? 0
                        let deal = Deal(
                            customerName: customerName.trimmed(),
                            vehicle: vehicle.trimmed(),
                            dealNumber: dealNumber.trimmed().isEmpty ? nil : dealNumber.trimmed(),
                            commission: value,
                            date: date
                        )
                        dealStore.addDeal(deal)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

private extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

#Preview {
    AddDealSheet()
        .environmentObject(DealStore())
}
