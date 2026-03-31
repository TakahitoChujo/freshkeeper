import Testing
import Foundation
@testable import FreshKeeper

@Suite("ConsumptionLog Tests")
struct ConsumptionLogTests {

    @Test("ConsumptionLog records consumed action correctly")
    func consumedLog() {
        let item = FoodItem(name: "テスト牛乳", expiryDate: .now, price: 250)
        let log = ConsumptionLog(foodItem: item, action: .consumed)

        #expect(log.foodItemId == item.id)
        #expect(log.foodName == "テスト牛乳")
        #expect(log.action == .consumed)
        #expect(log.price == 250)
    }

    @Test("ConsumptionLog records discarded action correctly")
    func discardedLog() {
        let item = FoodItem(name: "テスト食パン", expiryDate: .now, price: 150)
        let log = ConsumptionLog(foodItem: item, action: .discarded)

        #expect(log.action == .discarded)
        #expect(log.price == 150)
    }

    @Test("ConsumptionLog uses effectivePrice when price is nil")
    func effectivePriceUsed() {
        let item = FoodItem(name: "牛乳", expiryDate: .now) // no price set, dairy default = 200
        let log = ConsumptionLog(foodItem: item, action: .consumed)

        #expect(log.price == 200)
    }
}
