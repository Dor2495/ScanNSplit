//
//  CustomListForHomeView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 16/05/2025.
//

import SwiftUI

struct ReceiptRow: View {
    var merchantName: String
    var date: String
    var total: Double
    var peopleCount: Int
    

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(merchantName.isEmpty ? "Untitled Receipt" : merchantName)
                    .font(.headline)
                    .lineLimit(1)

                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .center, spacing: 8) {
                Text("\(total.toString)")
                    .font(.headline)
                
                HStack {
                    personIcon(peopleCount)
                        .foregroundStyle(Color.blue)
                        .frame(width: 50)
//                    if item.assignedPersonIds.count != 0 {
                        Text("\(peopleCount)")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Circle()
                                    .fill(Color.accentColor)
                            )
                            .foregroundColor(.white)
//                            .opacity(peopleCount == 0 ? 0 : 1)
//                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)        
    }
    
    private func personIcon(_ count: Int) -> Image {
        switch count {
        case 0, 1:
            return Image(systemName: "person.fill")
            
        case 2:
            return Image(systemName: "person.2.fill")
            
        default:
            return Image(systemName: "person.3.fill")
        }
    }
    
}

#Preview {
    ReceiptRow(merchantName: "Grocery Store", date: "May 16, 2025", total: 24.99, peopleCount: 3)
}
