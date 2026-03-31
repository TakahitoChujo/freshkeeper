import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query private var logs: [ConsumptionLog]
    @State private var viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthSelector
                    monthlyChartCard
                    monthlySummaryCard
                    cumulativeCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "statistics.title"))
        }
    }

    private var monthSelector: some View {
        HStack {
            Button { viewModel.previousMonth() } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(viewModel.selectedMonth.formatted(.dateTime.year().month()))
                .font(.headline)
            Spacer()
            Button { viewModel.nextMonth() } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }

    private var monthlyChartCard: some View {
        let data = viewModel.weeklySavings(logs)

        return VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "statistics.monthly_savings"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("¥\(viewModel.monthlySavings(logs).formatted())")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Chart(data) { item in
                BarMark(
                    x: .value("Week", item.label),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(.green.gradient)
                .cornerRadius(4)
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(preset: .aligned) { value in
                    AxisValueLabel {
                        if let amount = value.as(Int.self) {
                            Text("¥\(amount)")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var monthlySummaryCard: some View {
        let consumed = viewModel.monthlyConsumedLogs(logs)
        let discarded = viewModel.monthlyDiscardedLogs(logs)
        let rate = viewModel.consumptionRate(logs)

        return VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "statistics.monthly_summary"))
                .font(.headline)

            SummaryRow(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                title: String(localized: "statistics.consumed"),
                count: consumed.count,
                amount: viewModel.monthlySavings(logs)
            )

            SummaryRow(
                icon: "trash.circle.fill",
                iconColor: .red,
                title: String(localized: "statistics.discarded"),
                count: discarded.count,
                amount: viewModel.monthlyLoss(logs)
            )

            Divider()

            HStack {
                Text(String(localized: "statistics.consumption_rate"))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(rate))%")
                    .font(.title2.bold())
                    .foregroundStyle(rate >= 70 ? .green : .orange)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var cumulativeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "statistics.cumulative"))
                .font(.headline)

            HStack {
                VStack(alignment: .leading) {
                    Text(String(localized: "statistics.total_savings"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("¥\(viewModel.totalSavings(logs).formatted())")
                        .font(.title2.bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(String(localized: "statistics.total_registered"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalRegistered(logs))")
                        .font(.title2.bold())
                }
            }

            HStack {
                Text(String(localized: "statistics.overall_rate"))
                    .foregroundStyle(.secondary)
                Spacer()
                let rate = viewModel.overallConsumptionRate(logs)
                Text("\(Int(rate))%")
                    .font(.title2.bold())
                    .foregroundStyle(rate >= 70 ? .green : .orange)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

private struct SummaryRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: Int
    let amount: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
            Text(title)
            Spacer()
            Text("\(count)\(String(localized: "unit.items"))")
                .foregroundStyle(.secondary)
            Text("¥\(amount.formatted())")
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self], inMemory: true)
}
