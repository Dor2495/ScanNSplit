//
//  ContentView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("settings")
                }
                .tag(1)
        }
    }
}

#Preview {
    
    let container = try! ModelContainer(
        for: Receipt.self, Person.self, ReceiptItem.self, SplitAssignment.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    ContentView()
        .modelContainer(container)
        .environmentObject(SettingsViewModel())
}
