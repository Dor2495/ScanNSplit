//
//  AddNewReceiptViewModel.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 15/05/2025.
//

import SwiftUI

@MainActor
class AddNewReceiptViewModel: ObservableObject {
    
    @Published var merchantName: String = ""
    @Published var date: Date = Date()
    @Published var people: [Person] = []
    @Published var items: [ReceiptItem] = []
    
    @Published var tip: Double = 10
    @Published var tax: Double = 18
    
    @Published var addPerson: Bool = false
    @Published var personName: String = ""
    
    @Published var addItem: Bool = false
    @Published var itemName: String = ""
    @Published var itemPrice: String = "0.0"
    
    @Published var colorIndex: Int = 0
    let colors: [String] = [
        "#89e23b", "#333333", "#ff9900", "#ff0000",
        "#00ff00", "#0000ff", "#9900ff", "#ff11ff"
    ]
    
    @Published var errorMessage: String? = nil
    
    func resetInputs() {
        merchantName = ""
        date = Date()
        people = []
        items = []
        tip = 10
        tax = 18
        addPerson = false
        personName = ""
        addItem = false
        itemName = ""
        itemPrice = "0.0"
        colorIndex = 0
    }
    
    func saveNewReceipt() -> Receipt {
        if items.isEmpty {
            // show error message
            errorMessage = "No items..."
        } 
        
//        let totalSubtotal = items.map(\.price).reduce(0, +)
//        let totalTaxAmount = totalSubtotal * tax / 100
//        let totalTipAmount = (totalSubtotal + totalTaxAmount) * tip / 100
//        let totalOwedBeforeAssignments: Double = totalSubtotal + totalTaxAmount + totalTipAmount
//        
//        print("\(totalSubtotal)")
//        print("\(totalTaxAmount)")
//        print("\(totalTipAmount)")
//        print("\(totalOwedBeforeAssignments)")
//        
//        var assignments: [SplitAssignment] = []
//        
//        for person in people {
//            let assignedItems = items.filter { $0.assignedPersonIds.contains(person.id) }
//            let itemIds = assignedItems.map(\.id)
//            
//            let subTotal = assignedItems.map { item -> Double in
//                let sharedCount = max(item.assignedPersonIds.count, 1) // Avoid division by zero
//                return item.price / Double(sharedCount)
//            }.reduce(0.0, +) // Use 0.0 to clarify this is a Double reduction
//
//            _ = subTotal / totalSubtotal // will use for chart 
//
//            let taxShare = totalSubtotal > 0 ? (subTotal / totalSubtotal) * totalTaxAmount : 0
//            let tipShare = totalSubtotal > 0 ? (subTotal / totalSubtotal) * totalTipAmount : 0
//            let totalOwed = subTotal + taxShare + tipShare
//            
//            assignments.append(
//                SplitAssignment(
//                    personId: person.id,
//                    itemIds: itemIds,
//                    subTotal: subTotal,
//                    taxShare: taxShare,
//                    tipShare: tipShare,
//                    totalOwed: totalOwed
//                )
//            )
//        }
//        
//        let newReceipt = Receipt(
//            date: date,
//            merchantName: merchantName,
//            totalAmount: totalSubtotal,
//            taxAmount: totalTaxAmount,
//            tipAmount: totalTipAmount,
//            items: items,
//            people: people,
//            assignments: assignments
//        )
        
        // GENERAL INFO OF RECEIPT
        let totalItemsPrice: Double = items.reduce(0) { $0 + $1.price } // to share tax with everyone
        
        let taxCut: Double = totalItemsPrice * tax / 100
        let totalItemsPriceWithTax: Double = totalItemsPrice + taxCut
        
        let tipCut: Double = totalItemsPriceWithTax * tip / 100
        
        // SPLIT TO EACH PERSON
        var assignments: [SplitAssignment] = []
        
        for person in people {
                  
            let assignedItems = items.filter { $0.assignedPersonIds.contains(person.id) }
            let itemIds = assignedItems.map(\.id)

            // sum of items price
            let subTotal = assignedItems.map { item -> Double in
                let sharedCount = max(item.assignedPersonIds.count, 1) // Avoid division by zero
                return item.price / Double(sharedCount)
            }.reduce(0.0, +) // Use 0.0 to clarify this is a Double reduction
            
            let taxShare = taxCut / Double(people.count)
            let tipShare = tipCut / Double(people.count)
            
            let totalOwed = subTotal + taxShare + tipShare
            
            assignments.append(
                            SplitAssignment(
                                personId: person.id,
                                itemIds: itemIds,
                                subTotal: subTotal,
                                taxShare: taxShare,
                                tipShare: tipShare,
                                totalOwed: totalOwed
                            )
                        )
        }
        
        let newReceipt = Receipt(
                    date: date,
                    merchantName: merchantName,
                    totalAmount: totalItemsPriceWithTax,
                    taxAmount: taxCut,
                    tipAmount: tipCut,
                    items: items,
                    people: people,
                    assignments: assignments
        )
        resetInputs()
        
        return newReceipt
        
    }
}
