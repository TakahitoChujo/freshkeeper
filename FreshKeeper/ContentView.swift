import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case scan
    case statistics

    var title: String {
        switch self {
        case .home: String(localized: "tab.home")
        case .scan: String(localized: "tab.scan")
        case .statistics: String(localized: "tab.statistics")
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .scan: "camera.fill"
        case .statistics: "chart.bar.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .home:
                        HomeView()
                    case .scan:
                        ScanView()
                    case .statistics:
                        StatisticsView()
                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self], inMemory: true)
}
