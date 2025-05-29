//
//  AppSettings.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

@Model
class AppSettings {
var defaultTipPercent: Double
var defaultTaxPercent: Double
var currency: String
var themeModeRaw: String
var themeMode: ThemeMode {
    get { ThemeMode(rawValue: themeModeRaw) ?? .system }
    set { themeModeRaw = newValue.rawValue }
    }

    init(defaultTipPercent: Double = 0.15, defaultTaxPercent: Double = 0.1,
         currency: String = "USD", themeMode: ThemeMode = .system) {
        self.defaultTipPercent = defaultTipPercent
        self.defaultTaxPercent = defaultTaxPercent
        self.currency = currency
        self.themeModeRaw = themeMode.rawValue
    }
}

enum ThemeMode: String, Codable {
    case system
    case light
    case dark
}
