import SwiftUI
import SwiftData

struct FoodDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var item: FoodItem
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text(item.displayEmoji)
                            .font(.system(size: 48))
                        VStack(alignment: .leading) {
                            TextField(String(localized: "detail.name"), text: $item.name)
                                .font(.title2.bold())
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                Section(String(localized: "detail.info")) {
                    DatePicker(
                        String(localized: "detail.expiry_date"),
                        selection: $item.expiryDate,
                        displayedComponents: .date
                    )

                    HStack {
                        Text(String(localized: "detail.days_remaining"))
                        Spacer()
                        Text(item.expiryStatus.remainingText(item.daysUntilExpiry))
                            .foregroundStyle(item.expiryStatus.color)
                            .fontWeight(.semibold)
                    }

                    Picker(String(localized: "detail.storage"), selection: $item.storageLocation) {
                        ForEach(StorageLocation.allCases) { location in
                            Label(location.displayName, systemImage: location.icon)
                                .tag(location)
                        }
                    }

                    Stepper(String(localized: "detail.quantity \(item.quantity)"), value: $item.quantity, in: 1...99)

                    if let barcode = item.barcode, !barcode.isEmpty {
                        HStack {
                            Text(String(localized: "detail.barcode"))
                            Spacer()
                            Text(barcode)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text(String(localized: "detail.registered"))
                        Spacer()
                        Text(item.createdAt.formatted(date: .numeric, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        Button {
                            item.markConsumed()
                            let log = ConsumptionLog(foodItem: item, action: .consumed)
                            modelContext.insert(log)
                            dismiss()
                        } label: {
                            Label(String(localized: "action.consume"), systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Button {
                            item.markDiscarded()
                            let log = ConsumptionLog(foodItem: item, action: .discarded)
                            modelContext.insert(log)
                            dismiss()
                        } label: {
                            Label(String(localized: "action.discard"), systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "action.back")) { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button { showingDeleteAlert = true } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .alert(String(localized: "detail.delete_confirm"), isPresented: $showingDeleteAlert) {
                Button(String(localized: "action.delete"), role: .destructive) {
                    modelContext.delete(item)
                    dismiss()
                }
                Button(String(localized: "action.cancel"), role: .cancel) {}
            }
        }
    }
}
