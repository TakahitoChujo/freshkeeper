#if DEBUG
import SwiftUI
import SwiftData

/// デバッグビルド時のみサンプル食品データを自動挿入する ViewModifier
struct SampleDataModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext

    func body(content: Content) -> some View {
        content
            .onAppear {
                insertIfNeeded()
            }
    }

    private func insertIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "sampleDataInserted") else { return }

        let samples: [(String, Int, StorageLocation, Int)] = [
            ("牛乳",       -2, .refrigerator, 200),
            ("ヨーグルト",   0, .refrigerator, 150),
            ("豆腐",        1, .refrigerator, 100),
            ("卵",          3, .refrigerator, 250),
            ("食パン",      5, .other,        180),
            ("鶏肉",        7, .freezer,      350),
            ("チーズ",      14, .refrigerator, 400),
            ("冷凍うどん",   30, .freezer,      300),
        ]

        for (name, daysOffset, location, price) in samples {
            let item = FoodItem(
                name: name,
                expiryDate: Calendar.current.date(byAdding: .day, value: daysOffset, to: .now)!,
                storageLocation: location,
                price: price
            )
            modelContext.insert(item)
        }

        try? modelContext.save()
        UserDefaults.standard.set(true, forKey: "sampleDataInserted")
    }
}
#endif
