import Testing
import Foundation
@testable import FreshKeeper

@Suite("DefaultPriceProvider Tests")
struct DefaultPriceProviderTests {

    @Test("Returns correct price for dairy products")
    func dairyPrice() {
        #expect(DefaultPriceProvider.defaultPrice(for: "牛乳") == 200)
        #expect(DefaultPriceProvider.defaultPrice(for: "ヨーグルト") == 200)
        #expect(DefaultPriceProvider.defaultPrice(for: "チーズ") == 200)
    }

    @Test("Returns correct price for bread")
    func breadPrice() {
        #expect(DefaultPriceProvider.defaultPrice(for: "食パン") == 150)
        #expect(DefaultPriceProvider.defaultPrice(for: "パン") == 150)
    }

    @Test("Returns correct price for meat")
    func meatPrice() {
        #expect(DefaultPriceProvider.defaultPrice(for: "鶏肉") == 400)
        #expect(DefaultPriceProvider.defaultPrice(for: "豚バラ") == 400)
    }

    @Test("Returns correct price for vegetables")
    func vegetablePrice() {
        #expect(DefaultPriceProvider.defaultPrice(for: "キャベツ") == 150)
        #expect(DefaultPriceProvider.defaultPrice(for: "トマト") == 150)
    }

    @Test("Returns correct price for seasonings")
    func seasoningPrice() {
        #expect(DefaultPriceProvider.defaultPrice(for: "醤油") == 300)
        #expect(DefaultPriceProvider.defaultPrice(for: "味噌") == 300)
    }

    @Test("Returns default price for unknown items")
    func unknownPrice() {
        #expect(DefaultPriceProvider.defaultPrice(for: "不明なもの") == 200)
    }
}
