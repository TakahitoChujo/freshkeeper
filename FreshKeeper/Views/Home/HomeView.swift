import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<FoodItem> { $0.statusRaw == "active" },
           sort: \FoodItem.expiryDate)
    private var activeItems: [FoodItem]
    @Query private var logs: [ConsumptionLog]

    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    savingsSummaryCard
                    filterChips
                    foodList
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "home.title"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { viewModel.showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { viewModel.showingNotifications = true } label: {
                        Image(systemName: "bell")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $viewModel.showingNotifications) {
                NotificationsView()
            }
        }
    }

    private var savingsSummaryCard: some View {
        let savings = viewModel.monthlySavings(logs)
        let lastMonth = viewModel.lastMonthSavings(logs)
        let diff = savings - lastMonth

        return SavingsSummaryCard(savings: savings, diff: diff)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipView(
                    title: String(localized: "filter.all"),
                    isSelected: viewModel.selectedFilter == nil
                ) {
                    viewModel.selectedFilter = nil
                }

                ForEach(StorageLocation.allCases) { location in
                    FilterChipView(
                        title: location.displayName,
                        isSelected: viewModel.selectedFilter == location
                    ) {
                        viewModel.selectedFilter = location
                    }
                }
            }
        }
    }

    private var foodList: some View {
        let items = viewModel.filteredItems(activeItems)

        return LazyVStack(spacing: 12) {
            if items.isEmpty {
                ContentUnavailableView(
                    String(localized: "home.empty.title"),
                    systemImage: "refrigerator",
                    description: Text(String(localized: "home.empty.description"))
                )
                .padding(.top, 40)
            } else {
                ForEach(items) { item in
                    FoodCardView(item: item) {
                        viewModel.consumeItem(item, context: modelContext)
                    } onDiscard: {
                        viewModel.discardItem(item, context: modelContext)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self], inMemory: true)
}
