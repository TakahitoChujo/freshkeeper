import SwiftUI
import SwiftData

@main
struct FreshKeeperApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    let modelContainer: ModelContainer

    init() {
        let useCloudKit = !UserDefaults.standard.bool(forKey: "iCloudSyncDisabledByUser")
        let schema = Schema([FoodItem.self, BarcodeProduct.self, ConsumptionLog.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: useCloudKit ? .automatic : .none
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                #if DEBUG
                .modifier(SampleDataModifier())
                #endif
                .task {
                    _ = await NotificationService.shared.requestPermission()
                }
                .fullScreenCover(isPresented: Binding(
                    get: { !hasCompletedOnboarding },
                    set: { if !$0 { hasCompletedOnboarding = true } }
                )) {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
        }
        .modelContainer(modelContainer)
    }
}
