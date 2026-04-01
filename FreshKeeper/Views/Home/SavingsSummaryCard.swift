import SwiftUI

struct SavingsSummaryCard: View {
    let savings: Int
    let diff: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "yensign.circle.fill")
                    .foregroundStyle(.green)
                Text(String(localized: "savings.monthly"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("¥\(savings.formatted())")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            if diff != 0 {
                HStack(spacing: 4) {
                    Image(systemName: diff > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    Text(String(localized: "savings.diff \(diff > 0 ? "+" : "")\(diff.formatted())"))
                        .font(.caption)
                }
                .foregroundStyle(diff > 0 ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
    }
}
