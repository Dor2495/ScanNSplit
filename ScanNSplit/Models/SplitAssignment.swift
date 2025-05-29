//
//  SplitAssignment.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

@Model
class SplitAssignment: Hashable {
    @Attribute(.unique) var id: String
    var personId: String
    var itemIds: [String]
    var subTotal: Double
    var taxShare: Double
    var tipShare: Double
    var totalOwed: Double
    
    init(id: String = UUID().uuidString, personId: String, itemIds: [String] = [],
         subTotal: Double = 0, taxShare: Double = 0, tipShare: Double = 0, totalOwed: Double = 0) {
        self.id = id
        self.personId = personId
        self.itemIds = itemIds
        self.subTotal = subTotal
        self.taxShare = taxShare
        self.tipShare = tipShare
        self.totalOwed = totalOwed
    }

    var formattedTotal: String {
        totalOwed.formatted(.currency(code: "USD"))
    }
    
    var formattedSubtotal: String {
        subTotal.formatted(.currency(code: "USD"))
    }
    
    var formattedTax: String {
        taxShare.formatted(.currency(code: "USD"))
    }
    
    var formattedTip: String {
        tipShare.formatted(.currency(code: "USD"))
    }

//    var totalOwedString: String {
//        String(format: "%.2f", totalOwed)
//    }
//
//    var taxShareString: String {
//        String(format: "%.2f", taxShare)
//    }   
//
//    var tipShareString: String {
//        String(format: "%.2f", tipShare)
//    }
//
//    var subTotalString: String {
//        String(format: "%.2f", subTotal)
//    }
}
