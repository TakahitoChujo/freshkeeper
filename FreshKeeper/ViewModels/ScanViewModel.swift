import SwiftUI
import SwiftData
import AVFoundation
import Vision

@Observable
final class ScanViewModel {
    var detectedBarcode: String?
    var detectedDates: [Date] = []
    var selectedDate: Date?
    var productName: String = ""
    var storageLocation: StorageLocation = .refrigerator
    var quantity: Int = 1
    var price: String = ""
    var isCameraActive = true
    var showingResult = false
    var continuousScanMode = false

    private static let maxProductNameLength = 100
    private static let maxPrice = 999_999

    var canRegister: Bool {
        !productName.isEmpty && selectedDate != nil
    }

    /// Sanitized product name, truncated to safe length
    var sanitizedProductName: String {
        String(productName.prefix(Self.maxProductNameLength))
    }

    /// Validated price, nil if invalid or out of range
    var validatedPrice: Int? {
        guard let value = Int(price), value >= 0, value <= Self.maxPrice else { return nil }
        return value
    }

    func processOCRResults(_ text: String) {
        let dates = DateParsingService.parseDates(from: text)
        if !dates.isEmpty {
            detectedDates = dates
            if selectedDate == nil {
                selectedDate = dates.first
            }
        }
    }

    func processBarcodeResult(_ barcode: String, context: ModelContext) {
        detectedBarcode = barcode

        let descriptor = FetchDescriptor<BarcodeProduct>(
            predicate: #Predicate { $0.barcode == barcode }
        )
        if let product = try? context.fetch(descriptor).first {
            productName = product.name
        }
    }

    func registerItem(context: ModelContext) {
        guard let date = selectedDate else { return }

        let item = FoodItem(
            name: sanitizedProductName,
            expiryDate: date,
            storageLocation: storageLocation,
            quantity: quantity,
            barcode: detectedBarcode,
            price: validatedPrice
        )
        context.insert(item)

        // Save barcode to local DB for future lookups
        if let barcode = detectedBarcode, !barcode.isEmpty {
            let descriptor = FetchDescriptor<BarcodeProduct>(
                predicate: #Predicate { $0.barcode == barcode }
            )
            if (try? context.fetch(descriptor).first) == nil {
                let product = BarcodeProduct(barcode: barcode, name: productName)
                context.insert(product)
            }
        }

        NotificationService.shared.scheduleNotifications(for: item)
        WidgetDataService.update(context: context)

        if continuousScanMode {
            resetForNextScan()
        } else {
            showingResult = false
        }
    }

    func resetForNextScan() {
        detectedBarcode = nil
        detectedDates = []
        selectedDate = nil
        productName = ""
        storageLocation = .refrigerator
        quantity = 1
        price = ""
        showingResult = false
        isCameraActive = true
    }

    func reset() {
        resetForNextScan()
        continuousScanMode = false
    }
}
