import Foundation

struct NotificationSetting: Hashable {
    var hour: Int
    var minute: Int
    var weekdays: Set<Int> // 1=Sun ... 7=Sat (Calendar.component(.weekday))
}


