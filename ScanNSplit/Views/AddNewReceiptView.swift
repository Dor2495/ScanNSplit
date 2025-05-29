//
//  AddNewReceiptView.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI

struct AddNewReceiptView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var addNewReceiptViewModel: AddNewReceiptViewModel
    @EnvironmentObject var settingsViewMModel: SettingsViewModel
    
    var saveReceipt: (Receipt) -> Void
    
    
    var body: some View {
        NavigationStack {
            Form {
                merchantSection
                
                dateSection
                taxTipSection
                
                peopleSection
                
                itemsSection
                
            }
            .navigationTitle("New Receipt")
            .toolbar {
                Button("Save") {
                    let newReceipt = save()
                    
                    saveReceipt(newReceipt)
                    dismiss()
                }
            }
        }
        .onChange(of: settingsViewMModel.defaultTax) { _, newValue in
            addNewReceiptViewModel.tax = newValue
        }
        .onChange(of: settingsViewMModel.defaultTip) { _, newValue in
            addNewReceiptViewModel.tip = newValue
        }
        .task {
            addNewReceiptViewModel.tax = settingsViewMModel.defaultTax
            addNewReceiptViewModel.tip = settingsViewMModel.defaultTip
        }
    }
    
    func save() -> Receipt {
        return addNewReceiptViewModel.saveNewReceipt()
    }
    
    var merchantSection: some View {
        Section("Merchant Name") {
            TextField("Merchant Name", text: $addNewReceiptViewModel.merchantName)
        }
    }
    
    var dateSection: some View {
        Section("Date") {
            DatePicker("Date", selection: $addNewReceiptViewModel.date)
                .datePickerStyle(.compact)
        }
    }
    
    var peopleSection: some View {
        Section {
            ForEach($addNewReceiptViewModel.people, id: \.id) { $person in
                
                Text(person.name)
                    .font(.body)
                
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        addNewReceiptViewModel.people.remove(at: addNewReceiptViewModel.people.firstIndex(of: person)!)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            
            if addNewReceiptViewModel.addPerson {
                HStack {
                    TextField("Person Name", text: $addNewReceiptViewModel.personName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !addNewReceiptViewModel.personName.isEmpty {
                            let color = addNewReceiptViewModel.colors[addNewReceiptViewModel.colorIndex]
                            
                            addNewReceiptViewModel.people.append(Person(name: addNewReceiptViewModel.personName, color: color))
                            
                            addNewReceiptViewModel.colorIndex += 1
                            addNewReceiptViewModel.personName = ""
                            addNewReceiptViewModel.addPerson = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
        } header: {
            HStack {
                Text("People")
                Spacer()
                Button {
                    withAnimation {
                        addNewReceiptViewModel.addPerson.toggle()
                    }
                } label: {
                    Label("Add Person", systemImage: "plus")
                        .font(.caption)
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
    
    var itemsSection: some View {
        Section {
            ForEach($addNewReceiptViewModel.items) { $item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text(String(format: "$%.2f", item.price))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Menu {
                        ForEach($addNewReceiptViewModel.people, id: \.id) { $person in
                            Button {
                                togglePersonAssignment(for: person.id, in: &item)
                            } label: {
                                HStack {
                                    Text(person.name)
                                    if item.assignedPersonIds.contains(person.id) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.2.fill")
                            if item.assignedPersonIds.count != 0 {
                                Text("\(item.assignedPersonIds.count)")
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                    )
                                    .foregroundColor(.white)
                                    .opacity(item.assignedPersonIds.isEmpty ? 0 : 1)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        addNewReceiptViewModel.items.remove(at: addNewReceiptViewModel.items.firstIndex(of: item)!)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            
            if addNewReceiptViewModel.addItem {
                HStack {
                    TextField("Item Name", text: $addNewReceiptViewModel.itemName)
                    TextField("Item Price", text: $addNewReceiptViewModel.itemPrice)
                        .keyboardType(.decimalPad)
                    Button("Add") {
                        if let price = Double(addNewReceiptViewModel.itemPrice), !addNewReceiptViewModel.itemName.isEmpty {
                            addNewReceiptViewModel.items.append(
                                ReceiptItem(name: addNewReceiptViewModel.itemName, price: price)
                            )
                            addNewReceiptViewModel.itemName = ""
                            addNewReceiptViewModel.itemPrice = "0.0"
                            addNewReceiptViewModel.addItem = false
                        }
                    }
                }
            }
            
        } header: {
            HStack {
                Text("Items")
                Spacer()
                Button {
                    withAnimation {
                        addNewReceiptViewModel.addItem.toggle()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    var taxTipSection: some View {
        Section("Tax & Tip") {
            HStack {
                Text("Tax (%)")
                Spacer()
                TextField("", value: $settingsViewMModel.defaultTax, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
            }
            
            HStack {
                Text("Tip (%)")
                Spacer()
                TextField("", value: $settingsViewMModel.defaultTip, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
            }
        }
    }
    
    private func togglePersonAssignment(for personId: String, in item: inout ReceiptItem) {
        if item.assignedPersonIds.contains(personId) {
            item.assignedPersonIds.removeAll { $0 == personId }
        } else {
            item.assignedPersonIds.append(personId)
        }
    }
}

struct PersonChip: View {
    @Binding var item: ReceiptItem
    var person: Person
    
    var body: some View {
        Button {
            toggleAssignment()
        } label: {
            Text(person.name)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .fill(isSelected ? Color(hex: person.color).opacity(0.3) : .clear)
                }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: isSelected)
    }
    
    private var isSelected: Bool {
        item.assignedPersonIds.contains(person.id)
    }
    
    private func toggleAssignment() {
        if isSelected {
            item.assignedPersonIds.removeAll { $0 == person.id }
        } else {
            item.assignedPersonIds.append(person.id)
        }
    }
}

#Preview {
    AddNewReceiptView(saveReceipt: {_ in }).environmentObject(AddNewReceiptViewModel()).environmentObject(SettingsViewModel())
}


