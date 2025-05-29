 import SwiftUI

 struct TempAddNewReceipt: View {
     @Environment(\.dismiss) private var dismiss
     @EnvironmentObject var viewModel: AddNewReceiptViewModel
    
     @State private var step = 1
     @State private var currentItems: [ReceiptItem] = []
     @State private var personItems: [Person: [ReceiptItem]] = [:]
     @State private var showReviewItemsButton: Bool? = false
     @State private var sharedItems: [ReceiptItem] = []
    
     var saveReceipt: (Receipt) -> Void

     var body: some View {
         NavigationStack {
             VStack(spacing: 0) {
                 StepIndicatorView(currentStep: step)
                     .padding(.top)
                
                 ScrollView {
                     VStack(spacing: 24) {
                         switch step {
                         case 1:
                             PersonEntryView(
                                 personName: $viewModel.personName,
                                 items: $currentItems,
                                 itemName: $viewModel.itemName,
                                 itemPrice: $viewModel.itemPrice,
                                 showReviewItemsButton: $showReviewItemsButton,
                                 step: $step,
                                 people: viewModel.people,
                                 onNext: {
                                     addCurrentPersonAndProceed()
                                     showReviewItemsButton = true
                                 }, navigateToReview: { to in
                                     navigate(from: step, to)
                                 }
                             )
                             .transition(.asymmetric(
                                 insertion: .move(edge: .trailing).combined(with: .opacity),
                                 removal: .move(edge: .leading).combined(with: .opacity)
                             ))
                            
                         case 2:
                             ReviewPeopleView(
                                 people: viewModel.people,
                                 items: personItems,
                                 sharedItems: $sharedItems,
                                 onAddAnother: {
                                     viewModel.personName = ""
                                     currentItems = []
                                     navigate(from: step, 1)
                                 },
                                 onContinue: {
                                     navigate(from: step, 3)
                                 }, onDelete: { id in
                                     viewModel.people.removeAll(where: { $0.id == id })
                                     personItems = personItems.filter { $0.key.id != id }
                                 },
                                 onEdit: { id in
                                     if let person = viewModel.people.first(where: { $0.id == id }),
                                        let items = personItems[person] {
                                         viewModel.personName = person.name
                                         currentItems = items
                                         personItems.removeValue(forKey: person)
                                         viewModel.people.removeAll(where: { $0.id == id })
                                         navigate(from: step, 1)
                                     }
                                 }
                             )
                             .transition(.asymmetric(
                                 insertion: .move(edge: .trailing).combined(with: .opacity),
                                 removal: .move(edge: .leading).combined(with: .opacity)
                             ))
                            
                         case 3:
                             FinalizeReceiptView(
                                 merchantName: $viewModel.merchantName,
                                 date: $viewModel.date,
                                 tax: $viewModel.tax,
                                 tip: $viewModel.tip,
                                 totalAmount: calculateTotal(),
                                 onSave: {
                                     saveFinalReceipt()
                                 }, onBack: {
                                     navigate(from: step, 2)
                                 }
                             )
                             .transition(.asymmetric(
                                 insertion: .move(edge: .trailing).combined(with: .opacity),
                                 removal: .move(edge: .leading).combined(with: .opacity)
                             ))
                            
                         default:
                             EmptyView()
                         }
                     }
                     .padding()
                 }
             }
             .navigationTitle("New Receipt")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     if step == 3 {
                         Button("Save") {
                             saveFinalReceipt()
                         }
                     }
                 }
             }
             .animation(.spring(response: 0.6, dampingFraction: 0.8), value: step)
         }
     }

     private func calculateTotal() -> Double {
         let itemsTotal = personItems.values.flatMap { $0 }.reduce(0) { $0 + $1.price }
         let sharedTotal = sharedItems.reduce(0) { $0 + $1.price }
         return itemsTotal + sharedTotal + viewModel.tax + viewModel.tip
     }

     private func addCurrentPersonAndProceed() {
         guard !viewModel.personName.isEmpty, !currentItems.isEmpty else { return }

         let color = viewModel.colors[viewModel.colorIndex % viewModel.colors.count]
         let newPerson = Person(name: viewModel.personName, color: color)
         viewModel.colorIndex += 1

         viewModel.people.append(newPerson)
         personItems[newPerson] = currentItems

         viewModel.personName = ""
         currentItems = []

         navigate(from: step, 2)
     }

     private func saveFinalReceipt() {
         // Handle individual person items
         var allItems: [ReceiptItem] = []
        
         for (person, items) in personItems {
             for item in items {
                 let assignedItem = item
                 assignedItem.assignedPersonIds = [person.id]
                 allItems.append(assignedItem)
             }
         }
        
         // Handle shared items
         for item in sharedItems {
             let sharedItem = item
             sharedItem.assignedPersonIds = viewModel.people.map { $0.id }
             allItems.append(sharedItem)
         }
        
         viewModel.items = allItems

         let receipt = viewModel.saveNewReceipt()
         saveReceipt(receipt)
         dismiss()
     }

     private func navigate(from: Int? = nil, _ to: Int) {
         withAnimation {
             step = to
         }
     }
 }


 struct StepIndicatorView: View {
     let currentStep: Int
     let totalSteps = 3
     let labels = ["Person & Items", "Review", "Finalize"]
    
     var body: some View {
         VStack(spacing: 4) {
             HStack(spacing: 8) {
                 ForEach(1...totalSteps, id: \.self) { step in
                     Circle()
                         .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                         .frame(width: 12, height: 12)
                         .overlay(
                             Circle()
                                 .stroke(Color.blue, lineWidth: step == currentStep ? 2 : 0)
                                 .scaleEffect(1.5)
                         )
                         .animation(.spring(response: 0.3), value: currentStep)
                 }
             }
            
             Text(labels[currentStep - 1])
                 .font(.caption)
                 .foregroundColor(.secondary)
         }
         .padding(.vertical, 12)
     }
 }

 struct PersonEntryView: View {
     @Binding var personName: String
     @Binding var items: [ReceiptItem]
     @Binding var itemName: String
     @Binding var itemPrice: String
     @Binding var showReviewItemsButton: Bool?
    
     @Binding var step: Int
    
     var people: [Person]
    
     let onNext: () -> Void
    
     let navigateToReview: (Int) -> Void
    
     @State private var isAddingItem = false
     @State private var selectedItem: ReceiptItem?
     @State private var showColorIndicator = false

     var body: some View {
         // Person name input
         VStack(alignment: .leading, spacing: 8) {
             HStack {
                 Text("Who's paying?")
                     .font(.headline)
                     .foregroundColor(.secondary)
                
                 Spacer()
                
                 if !people.isEmpty {
                     Button(action: { showColorIndicator.toggle() }) {
                         Image(systemName: "circle.grid.2x2.fill")
                             .foregroundColor(.blue)
                     }
                 }
             }
            
             TextField("Enter name", text: $personName)
                 .textFieldStyle(.roundedBorder)
                 .font(.title3)
            
             if showColorIndicator && !people.isEmpty {
                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack(spacing: 12) {
                         ForEach(people) { person in
                             VStack {
                                 Circle()
                                     .fill(Color(hex: person.color))
                                     .frame(width: 20, height: 20)
                                
                                 Text(person.name)
                                     .font(.caption)
                             }
                         }
                     }
                     .padding(.vertical, 8)
                 }
             }
         }
        
         // Items list
         VStack(alignment: .leading, spacing: 12) {
             HStack {
                 Text("Items")
                     .font(.headline)
                     .foregroundColor(.secondary)
                
                 Spacer()
                
                 Button(action: { isAddingItem.toggle() }) {
                     Label(isAddingItem ? "Done" : "Add Item",
                           systemImage: isAddingItem ? "checkmark.circle.fill" : "plus.circle.fill")
                 }
                 .buttonStyle(.bordered)
             }
            
             if isAddingItem {
                 HStack {
                     TextField("Item name", text: $itemName)
                         .textFieldStyle(.roundedBorder)
                    
                     TextField("Price", text: $itemPrice)
                         .keyboardType(.decimalPad)
                         .textFieldStyle(.roundedBorder)
                         .frame(width: 100)
                    
                     Button(action: addItem) {
                         Image(systemName: "plus.circle.fill")
                             .foregroundColor(.blue)
                     }
                     .disabled(itemName.isEmpty || itemPrice.isEmpty)
                 }
                 .transition(.move(edge: .top).combined(with: .opacity))
             }
            
             // Items list
             if items.isEmpty {
                 Text("No items added yet")
                     .foregroundColor(.secondary)
                     .padding(.vertical)
             } else {
                 ForEach(items) { item in
                     HStack {
                         VStack(alignment: .leading) {
                             Text(item.name)
                                 .font(.body)
                            
                             Text(String(format: "$%.2f", item.price))
                                 .font(.subheadline)
                                 .foregroundColor(.secondary)
                         }
                        
                         Spacer()
                        
                         Button(action: {
                             if let index = items.firstIndex(where: { $0.id == item.id }) {
                                 items.remove(at: index)
                             }
                         }) {
                             Image(systemName: "trash")
                                 .foregroundColor(.red)
                         }
                     }
                     .padding(.vertical, 8)
                     .contentShape(Rectangle())
                     .onTapGesture {
                         selectedItem = item
                         itemName = item.name
                         itemPrice = String(format: "%.2f", item.price)
                         isAddingItem = true
                     }
                 }
             }
         }
         .padding()
         .background(Color(.systemGray6))
         .cornerRadius(12)
        
         Spacer()
        
         // Subtotal
         if !items.isEmpty {
             HStack {
                 Text("Subtotal:")
                     .font(.headline)
                
                 Spacer()
                
                 Text(String(format: "$%.2f", items.reduce(0) { $0 + $1.price }))
                     .font(.headline)
             }
             .padding(.horizontal)
         }
        
         // Next button
         Button(action: onNext) {
             HStack {
                 Text("Next")
                 Image(systemName: "arrow.right")
             }
             .frame(maxWidth: .infinity)
             .padding()
             .background(personName.isEmpty || items.isEmpty ? Color.gray : Color.blue)
             .foregroundColor(.white)
             .cornerRadius(12)
         }
         .disabled(disableButton)
        
         if showReviewItemsButton ?? false {
             // Review items page button
             Button {
                 navigateToReview(2)
             } label: {
                 Text("Review items")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.blue.opacity(0.8))
                     .foregroundColor(.white)
                     .cornerRadius(12)
             }
         }
     }
    
     var disableButton: Bool {
         personName.isEmpty || items.isEmpty
     }
    
     private func addItem() {
         if let price = Double(itemPrice), !itemName.isEmpty {
             withAnimation {
                 if let selectedItem = selectedItem, let index = items.firstIndex(where: { $0.id == selectedItem.id }) {
                     items[index] = ReceiptItem(id: selectedItem.id, name: itemName, price: price)
                     self.selectedItem = nil
                 } else {
                     items.append(ReceiptItem(name: itemName, price: price))
                 }
                 itemName = ""
                 itemPrice = ""
                 isAddingItem = false
             }
         }
     }
 }

 struct ReviewPeopleView: View {
     var people: [Person]
     var items: [Person: [ReceiptItem]]
     @Binding var sharedItems: [ReceiptItem]
    
     let onAddAnother: () -> Void
     let onContinue: () -> Void
     let onDelete: (String) -> Void
     let onEdit: (String) -> Void
    
     @State private var isAddingSharedItem = false
     @State private var sharedItemName = ""
     @State private var sharedItemPrice = ""

     var body: some View {
         VStack(spacing: 20) {
             ScrollView {
                 VStack(spacing: 16) {
                     // People and their items
                     ForEach(people) { person in
                         VStack(alignment: .leading, spacing: 12) {
                             HStack {
                                 Circle()
                                     .fill(Color(hex: person.color))
                                     .frame(width: 20, height: 20)
                                
                                 Text(person.name)
                                     .font(.headline)
                                
                                 Spacer()
                                
                                 Button {
                                     onEdit(person.id)
                                 } label: {
                                     Image(systemName: "pencil")
                                         .foregroundColor(.blue)
                                 }
                             }
                            
                             ForEach(items[person] ?? []) { item in
                                 HStack {
                                     Text(item.name)
                                     Spacer()
                                     Text(String(format: "$%.2f", item.price))
                                         .foregroundColor(.secondary)
                                 }
                                 .padding(.vertical, 4)
                             }
                            
                             Divider()
                            
                             HStack {
                                 Text("Subtotal")
                                     .fontWeight(.medium)
                                 Spacer()
                                 Text(String(format: "$%.2f", (items[person] ?? []).reduce(0) { $0 + $1.price }))
                                     .fontWeight(.medium)
                             }
                         }
                         .padding()
                         .background(Color(.systemGray6))
                         .contextMenu {
                             Button {
                                 onEdit(person.id)
                             } label: {
                                 Label("Edit", systemImage: "pencil")
                             }
                            
                             Button(role: .destructive) {
                                 onDelete(person.id)
                             } label: {
                                 Label("Delete", systemImage: "trash")
                             }
                         }
                         .cornerRadius(12)
                     }
                    
                     // Shared items section
                     VStack(alignment: .leading, spacing: 12) {
                         HStack {
                             Text("Shared Items")
                                 .font(.headline)
                            
                             Spacer()
                            
                             Button {
                                 isAddingSharedItem.toggle()
                             } label: {
                                 Label(isAddingSharedItem ? "Done" : "Add Shared Item", 
                                       systemImage: isAddingSharedItem ? "checkmark.circle.fill" : "plus.circle.fill")
                             }
                             .buttonStyle(.bordered)
                         }
                        
                         if isAddingSharedItem {
                             HStack {
                                 TextField("Item name", text: $sharedItemName)
                                     .textFieldStyle(.roundedBorder)
                                
                                 TextField("Price", text: $sharedItemPrice)
                                     .keyboardType(.decimalPad)
                                     .textFieldStyle(.roundedBorder)
                                     .frame(width: 100)
                                
                                 Button(action: addSharedItem) {
                                     Image(systemName: "plus.circle.fill")
                                         .foregroundColor(.blue)
                                 }
                                 .disabled(sharedItemName.isEmpty || sharedItemPrice.isEmpty)
                             }
                         }
                        
                         if sharedItems.isEmpty && !isAddingSharedItem {
                             Text("No shared items")
                                 .foregroundColor(.secondary)
                                 .padding(.vertical, 8)
                         } else {
                             ForEach(sharedItems) { item in
                                 HStack {
                                     Text(item.name)
                                     Spacer()
                                     Text(String(format: "$%.2f", item.price))
                                         .foregroundColor(.secondary)
                                    
                                     Button {
                                         if let index = sharedItems.firstIndex(where: { $0.id == item.id }) {
                                             sharedItems.remove(at: index)
                                         }
                                     } label: {
                                         Image(systemName: "trash")
                                             .foregroundColor(.red)
                                     }
                                 }
                                 .padding(.vertical, 4)
                             }
                            
                             if !sharedItems.isEmpty {
                                 Divider()
                                
                                 HStack {
                                     Text("Shared Total")
                                         .fontWeight(.medium)
                                     Spacer()
                                     Text(String(format: "$%.2f", sharedItems.reduce(0) { $0 + $1.price }))
                                         .fontWeight(.medium)
                                 }
                             }
                         }
                     }
                     .padding()
                     .background(Color(.systemGray6))
                     .cornerRadius(12)
                     .animation(.spring(response: 0.3), value: isAddingSharedItem)
                 }
             }
            
             HStack(spacing: 16) {
                 Button(action: onAddAnother) {
                     Label("Add Person", systemImage: "person.badge.plus")
                         .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.bordered)
                
                 Button(action: onContinue) {
                     Label("Continue", systemImage: "arrow.right")
                         .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.borderedProminent)
             }
         }
     }
    
     private func addSharedItem() {
         if let price = Double(sharedItemPrice), !sharedItemName.isEmpty {
             withAnimation {
                 sharedItems.append(ReceiptItem(name: sharedItemName, price: price))
                 sharedItemName = ""
                 sharedItemPrice = ""
                 isAddingSharedItem = false
             }
         }
     }
 }

 struct FinalizeReceiptView: View {
     @Binding var merchantName: String
     @Binding var date: Date
     @Binding var tax: Double
     @Binding var tip: Double
     var totalAmount: Double
    
     let onSave: () -> Void
     let onBack: () -> Void

     var body: some View {
         VStack(spacing: 24) {
             Text("Finalize Receipt")
                 .font(.title2)
                 .fontWeight(.bold)
            
             VStack(spacing: 20) {
                 // Merchant Details
                 VStack(alignment: .leading, spacing: 12) {
                     Text("Merchant Details")
                         .font(.headline)
                         .foregroundColor(.secondary)
                    
                     TextField("Merchant name", text: $merchantName)
                         .textFieldStyle(.roundedBorder)
                    
                     DatePicker("Date", selection: $date, displayedComponents: .date)
                         .datePickerStyle(.compact)
                 }
                 .padding()
                 .background(Color(.systemGray6))
                 .cornerRadius(12)
                
                 // Tax & Tip
                 VStack(alignment: .leading, spacing: 12) {
                     Text("Additional Charges")
                         .font(.headline)
                         .foregroundColor(.secondary)
                    
                     HStack {
                         Text("Tax")
                         Spacer()
                         TextField("0.00", value: $tax, format: .number)
                             .keyboardType(.decimalPad)
                             .multilineTextAlignment(.trailing)
                             .textFieldStyle(.roundedBorder)
                             .frame(width: 100)
                     }
                    
                     HStack {
                         Text("Tip")
                         Spacer()
                         TextField("0.00", value: $tip, format: .number)
                             .keyboardType(.decimalPad)
                             .multilineTextAlignment(.trailing)
                             .textFieldStyle(.roundedBorder)
                             .frame(width: 100)
                     }
                    
                     Divider()
                    
                     HStack {
                         Text("Total Amount")
                             .font(.headline)
                         Spacer()
                         Text(String(format: "$%.2f", totalAmount))
                             .font(.headline)
                     }
                 }
                 .padding()
                 .background(Color(.systemGray6))
                 .cornerRadius(12)
             }
            
             Spacer()
            
             Button(action: onSave) {
                 Label("Save Receipt", systemImage: "checkmark.circle.fill")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.blue)
                     .foregroundColor(.white)
                     .cornerRadius(12)
             }
            
             Button(action: onBack) {
                 Label("Back", systemImage: "arrow.left")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.blue.opacity(0.8))
                     .foregroundColor(.white)
                     .cornerRadius(12)
             }
         }
     }
 }

 #Preview {
     TempAddNewReceipt(saveReceipt: {_ in }).environmentObject(AddNewReceiptViewModel())
 }
