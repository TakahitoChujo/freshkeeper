import Testing
import Foundation
@testable import FreshKeeper

@Suite("FoodItem Tests")
struct FoodItemTests {

    @Test("Days until expiry calculates correctly for future dates")
    func daysUntilExpiryFuture() {
        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .day, value: 5, to: calendar.startOfDay(for: .now))!
        let item = FoodItem(name: "テスト牛乳", expiryDate: futureDate)
        #expect(item.daysUntilExpiry == 5)
    }

    @Test("Days until expiry is 0 for today")
    func daysUntilExpiryToday() {
        let today = Calendar.current.startOfDay(for: .now)
        let item = FoodItem(name: "テスト食パン", expiryDate: today)
        #expect(item.daysUntilExpiry == 0)
    }

    @Test("Days until expiry is negative for past dates")
    func daysUntilExpiryPast() {
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: .now))!
        let item = FoodItem(name: "テスト卵", expiryDate: pastDate)
        #expect(item.daysUntilExpiry == -3)
    }

    @Test("Expiry status returns correct values", arguments: [
        (0, ExpiryStatus.expired),
        (-1, ExpiryStatus.expired),
        (1, ExpiryStatus.urgent),
        (3, ExpiryStatus.urgent),
        (4, ExpiryStatus.warning),
        (7, ExpiryStatus.warning),
        (8, ExpiryStatus.safe),
        (30, ExpiryStatus.safe),
    ])
    func expiryStatusMapping(days: Int, expected: ExpiryStatus) {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: .now))!
        let item = FoodItem(name: "テスト", expiryDate: date)
        #expect(item.expiryStatus == expected)
    }

    @Test("Default values are set correctly on init")
    func defaultValues() {
        let item = FoodItem(name: "テスト", expiryDate: .now)
        #expect(item.quantity == 1)
        #expect(item.status == .active)
        #expect(item.storageLocation == .refrigerator)
        #expect(item.barcode == nil)
        #expect(item.price == nil)
        #expect(item.consumedAt == nil)
    }

    @Test("markConsumed changes status and sets consumedAt")
    func markConsumed() {
        let item = FoodItem(name: "テスト", expiryDate: .now)
        item.markConsumed()
        #expect(item.status == .consumed)
        #expect(item.consumedAt != nil)
    }

    @Test("markDiscarded changes status and sets consumedAt")
    func markDiscarded() {
        let item = FoodItem(name: "テスト", expiryDate: .now)
        item.markDiscarded()
        #expect(item.status == .discarded)
        #expect(item.consumedAt != nil)
    }

    @Test("effectivePrice returns price when set")
    func effectivePriceWithPrice() {
        let item = FoodItem(name: "テスト", expiryDate: .now, price: 500)
        #expect(item.effectivePrice == 500)
    }

    @Test("effectivePrice returns default when price is nil")
    func effectivePriceDefault() {
        let item = FoodItem(name: "牛乳", expiryDate: .now)
        #expect(item.effectivePrice == 200) // dairy default
    }

    @Test("displayEmoji returns correct emoji")
    func displayEmoji() {
        let milk = FoodItem(name: "牛乳", expiryDate: .now)
        #expect(milk.displayEmoji == "🥛")

        let bread = FoodItem(name: "食パン", expiryDate: .now)
        #expect(bread.displayEmoji == "🍞")

        let unknown = FoodItem(name: "不明なもの", expiryDate: .now)
        #expect(unknown.displayEmoji == "🍽️")
    }

    @Test("Storage location can be set via enum")
    func storageLocation() {
        let item = FoodItem(name: "テスト", expiryDate: .now, storageLocation: .freezer)
        #expect(item.storageLocation == .freezer)
        #expect(item.storageLocationRaw == "freezer")

        item.storageLocation = .other
        #expect(item.storageLocationRaw == "other")
    }
}
