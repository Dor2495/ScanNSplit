//
//  SettingsView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 15/05/2025.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General")) {
                    Picker("Currency", selection: $settingsViewModel.currencyRaw) {
                        ForEach(CurrencyFormat.allCases) { format in
                            Text(format.rawValue).tag(format.rawValue)
                        }
                    }

                    Picker("Default Tip", selection: $settingsViewModel.defaultTip) {
                        ForEach(settingsViewModel.tipPercent, id: \.self) { percent in
                            Text("\(String(percent))%").tag(percent)
                        }
                    }

                    Toggle("Round Totals", isOn: $settingsViewModel.roundTotals)

                    Picker("Split Method", selection: $settingsViewModel.splitMethodRaw) {
                        ForEach(SplitMethod.allCases) { method in
                            Text(method.rawValue).tag(method.rawValue)
                        }
                    }
                }

                Section(header: Text("Receipts")) {
                    Toggle("Auto-Save Receipt Images", isOn: $settingsViewModel.autoSaveReceiptImages)
                    Toggle("Auto Title from Merchant/Date", isOn: $settingsViewModel.defaultReceiptTitle)
                    Toggle("Auto-Assign Items to First Person", isOn: $settingsViewModel.autoAssignItemsToFirstPerson)
                }

                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $settingsViewModel.themeRaw) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView().environmentObject(SettingsViewModel())
}

