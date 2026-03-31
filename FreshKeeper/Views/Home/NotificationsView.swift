import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<FoodItem> { $0.statusRaw == "active" },
           sort: \FoodItem.expiryDate)
    private var activeItems: [FoodItem]

    private var alertItems: [FoodItem] {
        activeItems.filter { $0.expiryStatus != .safe }
    }

    private func items(for status: ExpiryStatus) -> [FoodItem] {
        alertItems.filter { $0.expiryStatus == status }
    }

    var body: some View {
        NavigationStack {
            Group {
                if alertItems.isEmpty {
                    ContentUnavailableView(
                        String(localized: "notifications.empty.title"),
                        systemImage: "bell.slash",
                        description: Text(String(localized: "notifications.empty.description"))
                    )
                } else {
                    List {
                        section(for: .expired)
                        section(for: .urgent)
                        section(for: .warning)
                    }
                }
            }
            .navigationTitle(String(localized: "notifications.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "action.done")) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func section(for status: ExpiryStatus) -> some View {
        let sectionItems = items(for: status)
        if !sectionItems.isEmpty {
            Section {
                ForEach(sectionItems) { item in
                    HStack {
                        Text(item.displayEmoji)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.body)
                            Text(status.remainingText(item.daysUntilExpiry))
                                .font(.caption)
                                .foregroundStyle(status.color)
                        }
                        Spacer()
                        Text(status.label)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(status.backgroundColor)
                            .foregroundStyle(status.color)
                            .clipShape(Capsule())
                    }
                }
            } header: {
                Text(status.label)
            }
        }
    }
}

#Preview {
    NotificationsView()
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self], inMemory: true)
}
