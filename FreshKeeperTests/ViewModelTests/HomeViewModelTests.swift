import Testing
import Foundation
import SwiftData
@testable import FreshKeeper

@Suite("HomeViewModel Tests")
struct HomeViewModelTests {

    private func makeItem(name: String, daysFromNow: Int, storage: StorageLocation = .refrigerator, status: FoodStatus = .active) -> FoodItem {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: daysFromNow, to: .now)!
        let item = FoodItem(name: name, expiryDate: date, storageLocation: storage)
        if status != .active {
            item.statusRaw = status.rawValue
        }
        return item
    }

    @Test("filteredItems returns only active items sorted by expiry date")
    func filteredItemsActive() {
        let vm = HomeViewModel()
        let items = [
            makeItem(name: "A", daysFromNow: 5),
            makeItem(name: "B", daysFromNow: 1),
            makeItem(name: "C", daysFromNow: 3, status: .consumed),
        ]

        let result = vm.filteredItems(items)
        #expect(result.count == 2)
        #expect(result[0].name == "B") // sooner expiry first
        #expect(result[1].name == "A")
    }

    @Test("filteredItems filters by storage location")
    func filteredItemsByStorage() {
        let vm = HomeViewModel()
        vm.selectedFilter = .freezer
        let items = [
            makeItem(name: "A", daysFromNow: 5, storage: .refrigerator),
            makeItem(name: "B", daysFromNow: 1, storage: .freezer),
        ]

        let result = vm.filteredItems(items)
        #expect(result.count == 1)
        #expect(result[0].name == "B")
    }

    @Test("filteredItems returns all active when no filter")
    func filteredItemsNoFilter() {
        let vm = HomeViewModel()
        vm.selectedFilter = nil
        let items = [
            makeItem(name: "A", daysFromNow: 5, storage: .refrigerator),
            makeItem(name: "B", daysFromNow: 1, storage: .freezer),
            makeItem(name: "C", daysFromNow: 3, storage: .other),
        ]

        let result = vm.filteredItems(items)
        #expect(result.count == 3)
    }

    @Test("monthlySavings calculates correct total for current month")
    func monthlySavings() {
        let vm = HomeViewModel()
        let logs = [
            makeLog(action: .consumed, price: 200, daysAgo: 1),
            makeLog(action: .consumed, price: 300, daysAgo: 5),
            makeLog(action: .discarded, price: 100, daysAgo: 2),
            makeLog(action: .consumed, price: 500, daysAgo: 40), // last month
        ]

        let result = vm.monthlySavings(logs)
        #expect(result == 500) // 200 + 300 (only consumed this month)
    }

    private func makeLog(action: ConsumptionAction, price: Int, daysAgo: Int) -> ConsumptionLog {
        let container = try! ModelContainer(for: FoodItem.self, ConsumptionLog.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let item = FoodItem(name: "テスト", expiryDate: .now, price: price)
        context.insert(item)
        let log = ConsumptionLog(foodItem: item, action: action)
        context.insert(log)
        // Use the 15th of the current month as a reference point so that
        // small daysAgo values stay within the current month.
        let calendar = Calendar.current
        let mid = calendar.date(from: calendar.dateComponents([.year, .month], from: .now))!
            .addingTimeInterval(14 * 24 * 60 * 60) // 15th of the month
        log.date = calendar.date(byAdding: .day, value: -daysAgo, to: mid)!
        return log
    }
}
