import SwiftUI
import SwiftData

@main
struct FreshKeeperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if DEBUG
                .modifier(SampleDataModifier())
                #endif
                .task {
                    _ = await NotificationService.shared.requestPermission()
                }
        }
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self])
    }
}
