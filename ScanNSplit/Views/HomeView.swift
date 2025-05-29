//
//  HomeView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Receipt.date, order: .reverse) var receipts: [Receipt]
    
    @StateObject var addNewReceiveViewModel = AddNewReceiptViewModel()
    @State var showAddNewReceiptSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(receipts, id: \.id) { receipt in
                    NavigationLink(destination: ReceiptSummaryView(receipt: receipt)) {
                        ReceiptRow(
                            merchantName: receipt.merchantName ?? "",
                            date: receipt.date.formatted(date: .abbreviated, time: .omitted),
                            total: receipt.totalAmount,
                            peopleCount: receipt.people.count
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: deleteReceipt)
            }
            .listRowSeparator(.hidden)
            .listStyle(.automatic)
            .sheet(isPresented: $showAddNewReceiptSheet) {
               AddNewReceiptView() { newReceipt in
                   save(newReceipt)
               }
               .environmentObject(addNewReceiveViewModel)
                
                // TempAddNewReceipt { receipt in
                //     save(receipt)
                // }
//                .environmentObject(addNewReceiveViewModel)
                
                
            }
            .navigationTitle("Receipts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddNewReceiptSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func deleteReceipt(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(receipts[offset])
        }
    }
    
    private func save(_ newReceipt: Receipt) {
        modelContext.insert(newReceipt)
    }
}

#Preview {
    HomeView()
}
