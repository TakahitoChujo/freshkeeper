import Testing
import Foundation
import SwiftData
@testable import FreshKeeper

@Suite("StatisticsViewModel Tests")
struct StatisticsViewModelTests {

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

    @Test("monthlySavings returns sum of consumed prices")
    func monthlySavings() {
        let vm = StatisticsViewModel()
        let logs = [
            makeLog(action: .consumed, price: 200, daysAgo: 1),
            makeLog(action: .consumed, price: 300, daysAgo: 2),
            makeLog(action: .discarded, price: 100, daysAgo: 1),
        ]

        #expect(vm.monthlySavings(logs) == 500)
    }

    @Test("monthlyLoss returns sum of discarded prices")
    func monthlyLoss() {
        let vm = StatisticsViewModel()
        let logs = [
            makeLog(action: .consumed, price: 200, daysAgo: 1),
            makeLog(action: .discarded, price: 100, daysAgo: 1),
            makeLog(action: .discarded, price: 150, daysAgo: 2),
        ]

        #expect(vm.monthlyLoss(logs) == 250)
    }

    @Test("consumptionRate calculates correctly")
    func consumptionRate() {
        let vm = StatisticsViewModel()
        let logs = [
            makeLog(action: .consumed, price: 200, daysAgo: 1),
            makeLog(action: .consumed, price: 300, daysAgo: 2),
            makeLog(action: .consumed, price: 300, daysAgo: 3),
            makeLog(action: .discarded, price: 100, daysAgo: 1),
        ]

        let rate = vm.consumptionRate(logs)
        #expect(rate == 75.0) // 3 consumed out of 4
    }

    @Test("consumptionRate is 0 when no logs")
    func consumptionRateEmpty() {
        let vm = StatisticsViewModel()
        #expect(vm.consumptionRate([]) == 0)
    }

    @Test("totalSavings sums all consumed logs")
    func totalSavings() {
        let vm = StatisticsViewModel()
        let logs = [
            makeLog(action: .consumed, price: 200, daysAgo: 1),
            makeLog(action: .consumed, price: 300, daysAgo: 40),
            makeLog(action: .discarded, price: 100, daysAgo: 1),
        ]

        #expect(vm.totalSavings(logs) == 500)
    }

    @Test("previousMonth and nextMonth navigate correctly")
    func monthNavigation() {
        let vm = StatisticsViewModel()
        let original = vm.selectedMonth

        vm.previousMonth()
        let prev = vm.selectedMonth

        vm.nextMonth()
        let afterNext = vm.selectedMonth

        let calendar = Calendar.current
        #expect(calendar.component(.month, from: prev) != calendar.component(.month, from: original))
        #expect(calendar.component(.month, from: afterNext) == calendar.component(.month, from: original))
    }

    @Test("weeklySavings groups by week")
    func weeklySavings() {
        let vm = StatisticsViewModel()
        let logs = [
            makeLog(action: .consumed, price: 200, daysAgo: 1),
            makeLog(action: .consumed, price: 300, daysAgo: 2),
        ]

        let weekly = vm.weeklySavings(logs)
        #expect(weekly.count == 5) // always 5 weeks
        let total = weekly.reduce(0) { $0 + $1.amount }
        #expect(total == 500)
    }
}
