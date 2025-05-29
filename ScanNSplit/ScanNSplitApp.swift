//
//  ScanNSplitApp.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI

@main
struct ScanNSplitApp: App {
    @StateObject var settingsViewModel = SettingsViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Receipt.self], inMemory: false)
                .environmentObject(settingsViewModel)
        }
    }
}
