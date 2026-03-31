import SwiftUI
import SwiftData

@main
struct FreshKeeperApp: App {
    let notificationService = NotificationService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                #if DEBUG
                .modifier(SampleDataModifier())
                #endif
        }
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self])
    }
}
