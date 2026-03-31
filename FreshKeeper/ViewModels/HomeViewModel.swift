import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var selectedFilter: StorageLocation?
    var showingSettings = false
    var showingNotifications = false

    func filteredItems(_ items: [FoodItem]) -> [FoodItem] {
        let activeItems = items.filter { $0.status == .active }
        let filtered: [FoodItem]
        if let filter = selectedFilter {
            filtered = activeItems.filter { $0.storageLocation == filter }
        } else {
            filtered = activeItems
        }
        return filtered.sorted { $0.expiryDate < $1.expiryDate }
    }

    func monthlySavings(_ logs: [ConsumptionLog]) -> Int {
        let calendar = Calendar.current
        let now = Date.now
        return logs
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .filter { $0.action == .consumed }
            .compactMap(\.price)
            .reduce(0, +)
    }

    func lastMonthSavings(_ logs: [ConsumptionLog]) -> Int {
        let calendar = Calendar.current
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: .now) else { return 0 }
        return logs
            .filter { calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) }
            .filter { $0.action == .consumed }
            .compactMap(\.price)
            .reduce(0, +)
    }

    func consumeItem(_ item: FoodItem, context: ModelContext) {
        item.markConsumed()
        let log = ConsumptionLog(foodItem: item, action: .consumed)
        context.insert(log)
        WidgetDataService.update(context: context)
    }

    func discardItem(_ item: FoodItem, context: ModelContext) {
        item.markDiscarded()
        let log = ConsumptionLog(foodItem: item, action: .discarded)
        context.insert(log)
        WidgetDataService.update(context: context)
    }
}
