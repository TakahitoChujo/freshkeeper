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
            (String(localized: "sample.milk"),          -2, .refrigerator, 200),
            (String(localized: "sample.yogurt"),          0, .refrigerator, 150),
            (String(localized: "sample.tofu"),             1, .refrigerator, 100),
            (String(localized: "sample.eggs"),             3, .refrigerator, 250),
            (String(localized: "sample.bread"),            5, .other,        180),
            (String(localized: "sample.chicken"),          7, .freezer,      350),
            (String(localized: "sample.cheese"),          14, .refrigerator, 400),
            (String(localized: "sample.frozen_udon"),     30, .freezer,      300),
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
