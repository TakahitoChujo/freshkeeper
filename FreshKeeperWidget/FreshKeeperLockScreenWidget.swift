import WidgetKit
import SwiftUI

struct FreshKeeperLockScreenWidget: Widget {
    let kind = "FreshKeeperLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FreshKeeperProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("期限切れ食品数")
        .description("期限切れ間近の食品数を表示します")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

private struct LockScreenWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: FreshKeeperEntry

    private var urgentCount: Int {
        entry.data.items.filter { $0.daysLeft <= 3 }.count
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryInline:
            inlineView
        case .accessoryRectangular:
            rectangularView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                Text("\(urgentCount)")
                    .font(.title2.bold())
            }
        }
    }

    private var inlineView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            if urgentCount > 0 {
                Text("期限間近 \(urgentCount)件")
            } else {
                Text("期限切れなし")
            }
        }
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("期限間近")
                    .font(.headline)
            }

            if entry.data.items.isEmpty {
                Text("食品なし")
                    .font(.caption)
            } else {
                ForEach(entry.data.items.prefix(2)) { item in
                    HStack {
                        Text(item.emoji)
                        Text(item.name)
                            .lineLimit(1)
                        Spacer()
                        Text("残\(item.daysLeft)日")
                    }
                    .font(.caption)
                }
            }
        }
    }
}

#Preview("Circular", as: .accessoryCircular) {
    FreshKeeperLockScreenWidget()
} timeline: {
    FreshKeeperEntry.placeholder
}

#Preview("Inline", as: .accessoryInline) {
    FreshKeeperLockScreenWidget()
} timeline: {
    FreshKeeperEntry.placeholder
}

#Preview("Rectangular", as: .accessoryRectangular) {
    FreshKeeperLockScreenWidget()
} timeline: {
    FreshKeeperEntry.placeholder
}
