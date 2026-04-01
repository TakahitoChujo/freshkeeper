import UserNotifications
import SwiftUI

final class NotificationService: Sendable {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleNotifications(for item: FoodItem) {
        let daysBefore = UserDefaults.standard.integer(forKey: "notificationDaysBefore")
        let notifyDays = daysBefore > 0 ? daysBefore : 3
        let notifyHour = UserDefaults.standard.integer(forKey: "notificationHour")
        let hour = (6...22).contains(notifyHour) ? notifyHour : 9

        let calendar = Calendar.current

        // Notification X days before (generic body - no food name on lock screen)
        if let notifyDate = calendar.date(byAdding: .day, value: -notifyDays, to: item.expiryDate) {
            scheduleNotification(
                id: "\(item.id)-before",
                title: String(localized: "notification.expiring_soon.title"),
                body: String(localized: "notification.expiring_soon.body.generic \(notifyDays)"),
                date: notifyDate,
                hour: hour
            )
        }

        // Notification on the day
        scheduleNotification(
            id: "\(item.id)-today",
            title: String(localized: "notification.today.title"),
            body: String(localized: "notification.today.body.generic"),
            date: item.expiryDate,
            hour: hour
        )

        // Notification day after expiry
        if let dayAfter = calendar.date(byAdding: .day, value: 1, to: item.expiryDate) {
            scheduleNotification(
                id: "\(item.id)-after",
                title: String(localized: "notification.expired.title"),
                body: String(localized: "notification.expired.body.generic"),
                date: dayAfter,
                hour: hour
            )
        }
    }

    func removeNotifications(for itemId: UUID) {
        let ids = ["-before", "-today", "-after"].map { "\(itemId)\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func scheduleNotification(id: String, title: String, body: String, date: Date, hour: Int) {
        let calendar = Calendar.current
        guard date > .now else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
