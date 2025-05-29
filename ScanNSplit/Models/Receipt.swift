//
//  Receipt.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftData
import Foundation

@Model
class Receipt {
    @Attribute(.unique) var id: String
    var date: Date
    var merchantName: String?
    var totalAmount: Double // including tax !
    var taxAmount: Double // tax cut from items prices
    var tipAmount: Double // tip cut from total amount
    
    @Relationship(deleteRule: .cascade) var items: [ReceiptItem]
    @Relationship(deleteRule: .cascade) var people: [Person]
    @Relationship(deleteRule: .cascade) var assignments: [SplitAssignment]
    
    init(id: String = UUID().uuidString, date: Date = Date(), merchantName: String? = nil,
         totalAmount: Double = 0, taxAmount: Double = 0, tipAmount: Double = 0,
         items: [ReceiptItem] = [], people: [Person] = [], assignments: [SplitAssignment] = []) {
        self.id = id
        self.date = date
        self.merchantName = merchantName
        self.totalAmount = totalAmount
        self.taxAmount = taxAmount
        self.tipAmount = tipAmount
        self.items = items
        self.people = people
        self.assignments = assignments
    }
}
