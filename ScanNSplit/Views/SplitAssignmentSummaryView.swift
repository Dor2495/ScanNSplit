//
//  SplitAssignmentSummaryView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 15/05/2025.
//

import SwiftUI

struct SplitAssignmentSummaryView: View {
    var assignment: SplitAssignment
    var person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(person.name)
                .font(.headline)

            HStack {
                // items price
                Text("Subtotal:")
                Spacer()
                Text(String(format: "$%.2f", assignment.subTotal))
            }

            HStack {
                // tax cut shared by all people
                Text("Tax:")
                Spacer()
                Text(String(format: "$%.2f", assignment.taxShare))
            }

            HStack {
                // tip cut shared by all people
                Text("Tip:")
                Spacer()
                Text(String(format: "$%.2f", assignment.tipShare))
            }

            Divider()

            HStack {
                Text("Total Owed:")
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "$%.2f", assignment.totalOwed))
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    SplitAssignmentSummaryView(
        assignment: SplitAssignment(
            id: "123",
            personId: "1234",
            itemIds: [],
            subTotal: 0,
            taxShare: 0,
            tipShare: 0,
            totalOwed: 0
        ),
        person: Person(name: "name")
    )
}
