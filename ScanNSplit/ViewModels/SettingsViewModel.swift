//
//  SettingsViewModel.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 16/05/2025.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var currencyRaw: String = CurrencyFormat.usd.rawValue
    @Published var defaultTip: Double = 10
    @Published var defaultTax: Double = 10
    @Published var roundTotals: Bool = false
    @Published var splitMethodRaw: String = SplitMethod.itemAssignment.rawValue
    @Published var autoSaveReceiptImages: Bool = false
    @Published var defaultReceiptTitle: Bool = true
    @Published var autoAssignItemsToFirstPerson: Bool = false
    @Published var themeRaw: String = AppTheme.system.rawValue
    
    let tipPercent = [10.0, 15.0, 20.0]
}

// MARK: Enums
enum CurrencyFormat: String, CaseIterable, Identifiable {
    case usd = "$"
    case nis = "₪"
    var id: String { rawValue }
}

enum SplitMethod: String, CaseIterable, Identifiable {
    case evenly = "Evenly"
    case itemAssignment = "Item Assignment"
    var id: String { rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    var id: String { rawValue }
}
