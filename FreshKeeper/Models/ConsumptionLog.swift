import Foundation
import SwiftData

enum ConsumptionAction: String, Codable {
    case consumed
    case discarded
}

@Model
final class ConsumptionLog {
    var id: UUID
    var foodItemId: UUID
    var foodName: String
    var actionRaw: String
    var price: Int?
    var date: Date

    var action: ConsumptionAction {
        get { ConsumptionAction(rawValue: actionRaw) ?? .consumed }
        set { actionRaw = newValue.rawValue }
    }

    init(foodItem: FoodItem, action: ConsumptionAction) {
        self.id = UUID()
        self.foodItemId = foodItem.id
        self.foodName = foodItem.name
        self.actionRaw = action.rawValue
        self.price = foodItem.effectivePrice
        self.date = .now
    }
}
