import SwiftUI
import SwiftData

@Observable
final class StatisticsViewModel {
    var selectedMonth: Date = .now

    func monthlyConsumedLogs(_ logs: [ConsumptionLog]) -> [ConsumptionLog] {
        let calendar = Calendar.current
        return logs.filter {
            calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) && $0.action == .consumed
        }
    }

    func monthlyDiscardedLogs(_ logs: [ConsumptionLog]) -> [ConsumptionLog] {
        let calendar = Calendar.current
        return logs.filter {
            calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) && $0.action == .discarded
        }
    }

    func monthlySavings(_ logs: [ConsumptionLog]) -> Int {
        monthlyConsumedLogs(logs).compactMap(\.price).reduce(0, +)
    }

    func monthlyLoss(_ logs: [ConsumptionLog]) -> Int {
        monthlyDiscardedLogs(logs).compactMap(\.price).reduce(0, +)
    }

    func consumptionRate(_ logs: [ConsumptionLog]) -> Double {
        let consumed = monthlyConsumedLogs(logs).count
        let discarded = monthlyDiscardedLogs(logs).count
        let total = consumed + discarded
        guard total > 0 else { return 0 }
        return Double(consumed) / Double(total) * 100
    }

    func totalSavings(_ logs: [ConsumptionLog]) -> Int {
        logs.filter { $0.action == .consumed }.compactMap(\.price).reduce(0, +)
    }

    func totalRegistered(_ logs: [ConsumptionLog]) -> Int {
        logs.count
    }

    func overallConsumptionRate(_ logs: [ConsumptionLog]) -> Double {
        let consumed = logs.filter { $0.action == .consumed }.count
        let total = logs.count
        guard total > 0 else { return 0 }
        return Double(consumed) / Double(total) * 100
    }

    func weeklySavings(_ logs: [ConsumptionLog]) -> [WeeklySaving] {
        let calendar = Calendar.current
        let consumed = monthlyConsumedLogs(logs)

        // Group by week of month
        var weeklyTotals: [Int: Int] = [:]
        for log in consumed {
            let weekOfMonth = calendar.component(.weekOfMonth, from: log.date)
            weeklyTotals[weekOfMonth, default: 0] += log.price ?? 0
        }

        return (1...5).map { week in
            WeeklySaving(week: week, amount: weeklyTotals[week] ?? 0)
        }
    }

    func previousMonth() {
        if let date = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = date
        }
    }

    func nextMonth() {
        if let date = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = date
        }
    }
}

struct WeeklySaving: Identifiable {
    let week: Int
    let amount: Int
    var id: Int { week }

    var label: String { "W\(week)" }
}
