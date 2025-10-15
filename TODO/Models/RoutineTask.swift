import Foundation

struct RoutineTask: Identifiable, Hashable {
    let id: UUID
    var title: String
    var notification: NotificationSetting?
    var completionLogs: [CompletionLog]

    init(id: UUID = UUID(), title: String, notification: NotificationSetting? = nil, completionLogs: [CompletionLog] = []) {
        self.id = id
        self.title = title
        self.notification = notification
        self.completionLogs = completionLogs
    }
}

extension RoutineTask {
    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completionLogs.contains { calendar.isDateInToday($0.date) }
    }

    var streakCount: Int {
        // 直近からの連続達成日数を概算（シンプル版）
        let calendar = Calendar.current
        let dates = Set(completionLogs.map { calendar.startOfDay(for: $0.date) })
        var count = 0
        var cursor = calendar.startOfDay(for: Date())
        while dates.contains(cursor) {
            count += 1
            if let prev = calendar.date(byAdding: .day, value: -1, to: cursor) {
                cursor = prev
            } else {
                break
            }
        }
        return count
    }

    var notifyTimeString: String? {
        guard let notification else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        var components = DateComponents()
        components.hour = notification.hour
        components.minute = notification.minute
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return nil
    }
}


