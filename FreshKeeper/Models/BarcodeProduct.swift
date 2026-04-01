import Foundation
import SwiftData

@Model
final class BarcodeProduct {
    var barcode: String
    var name: String
    var defaultExpiryDays: Int?
    var category: String?

    init(barcode: String, name: String, defaultExpiryDays: Int? = nil, category: String? = nil) {
        self.barcode = barcode
        self.name = name
        self.defaultExpiryDays = defaultExpiryDays
        self.category = category
    }
}
