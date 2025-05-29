//
//  ReceiptSummaryView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 15/05/2025.
//

import SwiftUI
import Charts

struct ReceiptSummaryView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    let receipt: Receipt

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                
                Divider()
                    .padding()

                itemsSection

                Divider()
                    .padding()

                if receipt.people.count > 1 {
                    peopleBreakdownSection
                    BarmarkCharts()
                }
                
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // NAME AND DATE
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8){
                    Text(receipt.merchantName ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)

                    Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // TAX AND TIP %
            VStack(alignment: .trailing) {
                summaryLabel("Tax %", value: settingsViewModel.defaultTax)
                summaryLabel("Tip %", value: settingsViewModel.defaultTip)
            }
            .padding(.bottom)

            Section("Items") {
                ForEach(receipt.items, id: \.id) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(String(format: "\(settingsViewModel.currencyRaw) %.2f", item.price))
                        }

                        let peopleForItem = receipt.people.filter { item.assignedPersonIds.contains($0.id) }
                        if !peopleForItem.isEmpty {
                            Text("Assigned to: \(peopleForItem.map(\.name).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Total: \(receipt.totalAmount.toString)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("+ tax: \(receipt.taxAmount.toString)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("+ tip: \(receipt.tipAmount.toString)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        
                    Text("\((receipt.totalAmount + receipt.tipAmount).toString) \(settingsViewModel.currencyRaw)")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    
                }
            }
        }
    }

    private var peopleBreakdownSection: some View {
        Section("Split Summary") {
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 20) {
                    ForEach(receipt.assignments) { assignment in
                        if let person = receipt.people.first(where: { $0.id == assignment.personId }) {
                            PersonSummaryCard(person: person, assignment: assignment, currency: settingsViewModel.currencyRaw)
//                                .contentMargins(EdgeInsets)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical)
            }
            .scrollTargetBehavior(.viewAligned)
            .contentTransition(.opacity)
            .scrollClipDisabled()
        }
    }
    
    private struct PersonCostCategory: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let label: String
        let value: Double
    }
    
    @ViewBuilder
    private func BarmarkCharts() -> some View {
        let barData: [PersonCostCategory] = receipt.assignments.compactMap { assignment in
            receipt.people.first(where: { $0.id == assignment.personId }).map { person in
                [
                    PersonCostCategory(name: person.name, label: "Subtotal", value: assignment.subTotal),
                    PersonCostCategory(name: person.name, label: "Tax", value: assignment.taxShare),
                    PersonCostCategory(name: person.name, label: "Tip", value: assignment.tipShare)
                ]
            }
        }
        .flatMap { $0 }

        Section("Cost Breakdown Per Person"){
            Chart {
                ForEach(barData) { entry in
                    BarMark(
                        x: .value("Person", entry.name),
                        y: .value(entry.label, entry.value)
                    )
                    .foregroundStyle(by: .value("Category", entry.label))
                }
            }
            .frame(height: 240)
            .chartLegend(position: .bottom)
            .padding()
        }
    }

    private struct PersonSummaryCard: View {
        let person: Person
        let assignment: SplitAssignment
        let currency: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Circle()
                        .fill(Color(hex: person.color))
                        .frame(width: 20, height: 20)
                    Text(person.name)
                        .font(.headline)
                }
                
                Divider()
                
                amountRow("Subtotal", formattedValue: assignment.subTotal.toString)
                amountRow("Tax", formattedValue: assignment.taxShare.toString)
                amountRow("Tip", formattedValue: assignment.tipShare.toString)
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text("\(currency) \(assignment.totalOwed.toString)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2)
            .frame(width: 200)
        }
        
        private func amountRow(_ label: String, formattedValue: String) -> some View {
            HStack {
                Text(label)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formattedValue)
            }
            .font(.subheadline)
        }
    }

    private func formatCurrency(_ amount: Double, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }

    private func summaryLabel(_ label: String, value: Double, _ space: Bool = false) -> some View {
        HStack(alignment: .center) {
            if space {
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                Divider()
                Text(String(format: "%.2f", value))
            } else {
                Spacer()
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                Text(String(format: "%.1f", value))
            }
        }
    }
}

#Preview {
    let samplePeople = [
    Person(name: "Alice"),
    Person(name: "Bob")
    ]

    let sampleItems = [
        ReceiptItem(name: "Burger", price: 10.0, assignedPersonIds: [samplePeople[0].id]),
        ReceiptItem(name: "Fries", price: 5.0, assignedPersonIds: [samplePeople[1].id]),
        ReceiptItem(name: "Soda", price: 3.0, assignedPersonIds: [samplePeople[0].id, samplePeople[1].id])
    ]

    let sampleAssignments = [
        SplitAssignment(personId: samplePeople[0].id, itemIds: [sampleItems[0].id, sampleItems[2].id], subTotal: 11.5, taxShare: 0.5, tipShare: 1.0, totalOwed: 13.0),
        SplitAssignment(personId: samplePeople[1].id, itemIds: [sampleItems[1].id, sampleItems[2].id], subTotal: 6.5, taxShare: 0.3, tipShare: 0.6, totalOwed: 7.4)
    ]

    let sampleReceipt = Receipt(id: UUID().uuidString,
        date: Date(),
        merchantName: "The Grill House",
        totalAmount: 18.0,
        taxAmount: 18,
        tipAmount: 10,
        items: sampleItems,
        people: samplePeople,
        assignments: sampleAssignments
    )

    ReceiptSummaryView(receipt: sampleReceipt).environmentObject(SettingsViewModel())
}
