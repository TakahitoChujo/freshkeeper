import Foundation
import SwiftData
import WidgetKit

enum WidgetDataService {
    /// Updates widget data from the current SwiftData context.
    /// Call this after any food item changes (add/consume/discard/delete).
    static func update(context: ModelContext) {
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { $0.statusRaw == "active" },
            sortBy: [SortDescriptor(\.expiryDate)]
        )
        guard let items = try? context.fetch(descriptor) else { return }

        let widgetItems = items.prefix(5).map { item in
            WidgetFoodItem(
                id: item.id.uuidString,
                name: item.name,
                emoji: item.displayEmoji,
                expiryDate: item.expiryDate,
                storageName: item.storageLocation.displayName,
                daysLeft: item.daysUntilExpiry
            )
        }

        // Calculate monthly savings
        let logDescriptor = FetchDescriptor<ConsumptionLog>()
        let logs = (try? context.fetch(logDescriptor)) ?? []
        let calendar = Calendar.current
        let monthlySavings = logs
            .filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) && $0.action == .consumed }
            .compactMap(\.price)
            .reduce(0, +)

        let data = WidgetData(items: Array(widgetItems), monthlySavings: monthlySavings)
        WidgetData.save(data)

        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Shared types (duplicated for App ↔ Widget boundary)

struct WidgetFoodItem: Codable, Identifiable {
    let id: String
    let name: String
    let emoji: String
    let expiryDate: Date
    let storageName: String
    let daysLeft: Int
}

struct WidgetData: Codable {
    let items: [WidgetFoodItem]
    let monthlySavings: Int

    static let empty = WidgetData(items: [], monthlySavings: 0)

    static func load() -> WidgetData {
        guard let defaults = UserDefaults(suiteName: "group.com.freshkeeper.shared"),
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }

    static func save(_ data: WidgetData) {
        guard let defaults = UserDefaults(suiteName: "group.com.freshkeeper.shared"),
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: "widgetData")
    }
}
