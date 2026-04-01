import WidgetKit
import SwiftUI

// MARK: - Shared Data Model (App ↔ Widget via App Group UserDefaults)

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

    /// Reads shared data from App Group UserDefaults
    static func load() -> WidgetData {
        guard let defaults = UserDefaults(suiteName: "group.com.jyojorian.freshkeeper"),
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }

    /// Writes shared data from the main app
    static func save(_ data: WidgetData) {
        guard let defaults = UserDefaults(suiteName: "group.com.jyojorian.freshkeeper"),
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: "widgetData")
    }
}

// MARK: - Timeline Provider

struct FreshKeeperProvider: TimelineProvider {
    func placeholder(in context: Context) -> FreshKeeperEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FreshKeeperEntry) -> Void) {
        completion(context.isPreview ? .placeholder : FreshKeeperEntry(date: .now, data: WidgetData.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FreshKeeperEntry>) -> Void) {
        let entry = FreshKeeperEntry(date: .now, data: WidgetData.load())
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct FreshKeeperEntry: TimelineEntry {
    let date: Date
    let data: WidgetData

    static let placeholder = FreshKeeperEntry(
        date: .now,
        data: WidgetData(
            items: [
                WidgetFoodItem(id: "1", name: "食パン", emoji: "🍞", expiryDate: .now, storageName: "冷蔵庫", daysLeft: 1),
                WidgetFoodItem(id: "2", name: "牛乳", emoji: "🥛", expiryDate: .now, storageName: "冷蔵庫", daysLeft: 3),
                WidgetFoodItem(id: "3", name: "卵", emoji: "🥚", expiryDate: .now, storageName: "冷蔵庫", daysLeft: 7),
            ],
            monthlySavings: 3200
        )
    )
}

// MARK: - Widget Definition (Small + Medium)

struct FreshKeeperWidget: Widget {
    let kind = "FreshKeeperWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FreshKeeperProvider()) { entry in
            FreshKeeperWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("期限切れ間近")
        .description("賞味期限が近い食品を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Views

struct FreshKeeperWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: FreshKeeperEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(items: entry.data.items)
        case .systemMedium:
            MediumWidgetView(items: entry.data.items, savings: entry.data.monthlySavings)
        default:
            SmallWidgetView(items: entry.data.items)
        }
    }
}

// MARK: - Small Widget

private struct SmallWidgetView: View {
    let items: [WidgetFoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
                Text("期限切れ間近")
                    .font(.caption.bold())
            }

            if items.isEmpty {
                Spacer()
                Text("食品なし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(items.prefix(3)) { item in
                    HStack {
                        Text(item.emoji)
                            .font(.caption)
                        Text(item.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text(daysText(item.daysLeft))
                            .font(.caption2.bold())
                            .foregroundStyle(colorFor(days: item.daysLeft))
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Medium Widget

private struct MediumWidgetView: View {
    let items: [WidgetFoodItem]
    let savings: Int

    var body: some View {
        HStack {
            // Left: food items
            VStack(alignment: .leading, spacing: 4) {
                Text("期限切れ間近")
                    .font(.caption.bold())

                if items.isEmpty {
                    Text("食品なし")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items.prefix(3)) { item in
                        HStack(spacing: 4) {
                            Text(item.emoji)
                                .font(.caption)
                            Text(item.name)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text(daysText(item.daysLeft))
                                .font(.caption2.bold())
                                .foregroundStyle(colorFor(days: item.daysLeft))
                            Text(item.storageName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 0)
            }

            Divider()

            // Right: savings
            VStack {
                Spacer()
                Text("今月")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("¥\(savings.formatted())")
                    .font(.title3.bold())
                    .foregroundStyle(.green)
                Text("節約 💰")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(width: 80)
        }
    }
}

// MARK: - Helpers

private func daysText(_ days: Int) -> String {
    if days <= 0 { return "期限切れ" }
    return "残\(days)日"
}

private func colorFor(days: Int) -> Color {
    switch days {
    case ...0: .red
    case 1...3: .red
    case 4...7: .orange
    default: .green
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    FreshKeeperWidget()
} timeline: {
    FreshKeeperEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    FreshKeeperWidget()
} timeline: {
    FreshKeeperEntry.placeholder
}
