import Foundation
import SwiftData

enum StorageLocation: String, Codable, CaseIterable, Identifiable {
    case refrigerator = "refrigerator"
    case freezer = "freezer"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .refrigerator: String(localized: "storage.refrigerator")
        case .freezer: String(localized: "storage.freezer")
        case .other: String(localized: "storage.other")
        }
    }

    var icon: String {
        switch self {
        case .refrigerator: "refrigerator.fill"
        case .freezer: "snowflake"
        case .other: "archivebox.fill"
        }
    }
}

enum FoodStatus: String, Codable {
    case active
    case consumed
    case discarded
}

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var expiryDate: Date
    var storageLocationRaw: String
    var quantity: Int
    var barcode: String?
    var statusRaw: String
    var price: Int?
    var createdAt: Date
    var consumedAt: Date?

    var storageLocation: StorageLocation {
        get { StorageLocation(rawValue: storageLocationRaw) ?? .other }
        set { storageLocationRaw = newValue.rawValue }
    }

    var status: FoodStatus {
        get { FoodStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: expiryDate)).day ?? 0
    }

    var expiryStatus: ExpiryStatus {
        ExpiryStatus.from(daysRemaining: daysUntilExpiry)
    }

    var displayEmoji: String {
        FoodEmojiMapper.emoji(for: name)
    }

    init(
        name: String,
        expiryDate: Date,
        storageLocation: StorageLocation = .refrigerator,
        quantity: Int = 1,
        barcode: String? = nil,
        price: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.expiryDate = expiryDate
        self.storageLocationRaw = storageLocation.rawValue
        self.quantity = quantity
        self.barcode = barcode
        self.statusRaw = FoodStatus.active.rawValue
        self.price = price
        self.createdAt = .now
        self.consumedAt = nil
    }

    func markConsumed() {
        status = .consumed
        consumedAt = .now
    }

    func markDiscarded() {
        status = .discarded
        consumedAt = .now
    }

    var effectivePrice: Int {
        if let price { return price }
        return DefaultPriceProvider.defaultPrice(for: name)
    }
}
