//
//  Extensions.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 15/05/2025.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        guard hexString.count == 6,
              let rgb = UInt64(hexString, radix: 16) else {
            // Fallback to gray color if parsing fails
            self = .gray
            return
        }

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self = Color(red: r, green: g, blue: b)
    }
}

extension Double {
    var toString: String {
        String(format: "%.2f", self)
    }
}
