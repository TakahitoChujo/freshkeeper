import SwiftUI

enum ExpiryStatus: CaseIterable {
    case expired
    case urgent
    case warning
    case safe

    static func from(daysRemaining: Int) -> ExpiryStatus {
        switch daysRemaining {
        case ...0: .expired
        case 1...3: .urgent
        case 4...7: .warning
        default: .safe
        }
    }

    var color: Color {
        switch self {
        case .expired: .red
        case .urgent: .red.opacity(0.8)
        case .warning: .orange
        case .safe: .green
        }
    }

    var backgroundColor: Color {
        switch self {
        case .expired: Color.red.opacity(0.12)
        case .urgent: Color.red.opacity(0.08)
        case .warning: Color.orange.opacity(0.08)
        case .safe: Color.green.opacity(0.08)
        }
    }

    var label: String {
        switch self {
        case .expired: String(localized: "expiry.expired")
        case .urgent: String(localized: "expiry.urgent")
        case .warning: String(localized: "expiry.warning")
        case .safe: String(localized: "expiry.safe")
        }
    }

    var remainingText: (Int) -> String {
        { days in
            switch self {
            case .expired:
                if days == 0 {
                    return String(localized: "expiry.today")
                }
                return String(localized: "expiry.days_over \(abs(days))")
            default:
                return String(localized: "expiry.days_left \(days)")
            }
        }
    }
}
