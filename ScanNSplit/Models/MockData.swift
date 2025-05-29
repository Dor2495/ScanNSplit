////
////  MockData.swift
////  ScanNSplit
////
////  Created by Dor Mizrachi on 14/05/2025.
////
//
//import Foundation
//
//let people: [Person] = [
//    Person(name: "Alice"),
//    Person(name: "Bob"),
//    Person(name: "Carol")
//]
//
//let items: [ReceiptItem] = [
//    ReceiptItem(name: "Pizza", price: 18.99, assignedPersonIds: [people[0].id]),
//    ReceiptItem(name: "Soda", price: 2.99, assignedPersonIds: [people[1].id]),
//    ReceiptItem(name: "Dessert", price: 6.49, assignedPersonIds: [people[0].id, people[2].id])
//]
//
//let assignments: [SplitAssignment] = [
//    SplitAssignment(
//        personId: people[0].id,
//        itemIds: [items[0].id, items[2].id],
//        subTotal: 18.99 + 6.49 / 2,
//        taxShare: 1.25,
//        tipShare: 1.50,
//        totalOwed: 18.99 + 6.49 / 2 + 1.25 + 1.50
//    ),
//    SplitAssignment(
//        personId: people[1].id,
//        itemIds: [items[1].id],
//        subTotal: 2.99,
//        taxShare: 0.25,
//        tipShare: 0.30,
//        totalOwed: 2.99 + 0.25 + 0.30
//    ),
//    SplitAssignment(
//        personId: people[2].id,
//        itemIds: [items[2].id],
//        subTotal: 6.49 / 2,
//        taxShare: 0.20,
//        tipShare: 0.25,
//        totalOwed: 6.49 / 2 + 0.20 + 0.25
//    )
//]
//
//let receipt: Receipt = Receipt(
//    date: Date(),
//    merchantName: "Joe's Pizza",
//    totalAmount: 28.47,
//    taxAmount: 1.70,
//    tipAmount: 2.05,
//    items: items,
//    people: people,
//    assignments: assignments
//)
//
