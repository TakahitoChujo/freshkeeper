import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("notificationDaysBefore") private var notificationDaysBefore: Int = 3
    @AppStorage("notificationHour") private var notificationHour: Int = 9
    @State private var exportFileURL: URL?
    @State private var showShareSheet = false

    private static let feedbackURL = URL(string: "mailto:feedback@freshkeeper.app")

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "settings.notifications")) {
                    Picker(String(localized: "settings.notify_before"), selection: $notificationDaysBefore) {
                        Text(String(localized: "settings.days_before \(1)")).tag(1)
                        Text(String(localized: "settings.days_before \(3)")).tag(3)
                        Text(String(localized: "settings.days_before \(7)")).tag(7)
                    }

                    Picker(String(localized: "settings.notify_time"), selection: $notificationHour) {
                        ForEach(6..<23) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                }

                Section(String(localized: "settings.data")) {
                    Button(String(localized: "settings.export")) {
                        exportData()
                    }
                }

                Section(String(localized: "settings.about")) {
                    HStack {
                        Text(String(localized: "settings.version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    if let url = Self.feedbackURL {
                        Link(String(localized: "settings.feedback"), destination: url)
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "action.done")) { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet, onDismiss: cleanupExportFile) {
                if let url = exportFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    private func exportData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let fetchDescriptor = FetchDescriptor<FoodItem>()
        guard let items = try? modelContext.fetch(fetchDescriptor) else { return }

        var csv = "\"名前\",\"賞味期限\",\"保管場所\",\"個数\",\"ステータス\",\"価格\",\"登録日\"\n"
        for item in items {
            let name = csvSanitize(item.name)
            let expiry = dateFormatter.string(from: item.expiryDate)
            let storage = csvSanitize(item.storageLocation.displayName)
            let status = item.status.rawValue
            let price = item.price.map(String.init) ?? ""
            let created = dateFormatter.string(from: item.createdAt)
            csv += "\(name),\"\(expiry)\",\(storage),\"\(item.quantity)\",\"\(status)\",\"\(price)\",\"\(created)\"\n"
        }

        let fileName = "FreshKeeper_\(dateFormatter.string(from: .now)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            exportFileURL = tempURL
            showShareSheet = true
        } catch {
            // Export failed silently
        }
    }

    private func cleanupExportFile() {
        if let url = exportFileURL {
            try? FileManager.default.removeItem(at: url)
            exportFileURL = nil
        }
    }

    /// Sanitize a string for safe CSV output: escape double quotes and strip leading formula characters.
    private func csvSanitize(_ value: String) -> String {
        var sanitized = value
        // Strip leading characters that trigger formula execution in spreadsheet apps
        while let first = sanitized.first, "=+\\-@\t\r".contains(first) {
            sanitized = String(sanitized.dropFirst())
        }
        // Escape embedded double quotes and wrap in double quotes
        sanitized = sanitized.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(sanitized)\""
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
