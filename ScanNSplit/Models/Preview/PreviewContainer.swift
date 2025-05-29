//
//  PreviewContainer.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

@MainActor
struct PreviewContainer {
static var modelContainer: ModelContainer {
    let schema = Schema([
        Receipt.self,
        ReceiptItem.self,
        Person.self,
        SplitAssignment.self,
        AppSettings.self
    ])

        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
