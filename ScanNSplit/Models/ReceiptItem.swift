//
//  ReceiptItem.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

@Model
class ReceiptItem {
    @Attribute(.unique) var id: String
    var name: String
    var price: Double
    var assignedPersonIds: [String]
    
    init(id: String = UUID().uuidString, name: String, price: Double, assignedPersonIds: [String] = []) {
        self.id = id
        self.name = name
        self.price = price
        self.assignedPersonIds = assignedPersonIds
    }
}
