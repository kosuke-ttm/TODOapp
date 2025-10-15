import Foundation
import Combine

final class InMemoryStore: ObservableObject {
    @Published private(set) var tasks: [RoutineTask]

    init() {
        self.tasks = [
            RoutineTask(title: "朝のストレッチ", notification: .init(hour: 7, minute: 0, weekdays: Set(2...6))),
            RoutineTask(title: "コーヒーを淹れる", notification: .init(hour: 8, minute: 0, weekdays: Set(1...7))),
            RoutineTask(title: "日記を書く", notification: .init(hour: 22, minute: 30, weekdays: Set(1...7)))
        ]
    }

    var todayTasks: [RoutineTask] {
        tasks
    }

    func toggleComplete(for task: RoutineTask) {
        guard let index = tasks.firstIndex(of: task) else { return }
        let calendar = Calendar.current
        if let todayIndex = tasks[index].completionLogs.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            tasks[index].completionLogs.remove(at: todayIndex)
        } else {
            tasks[index].completionLogs.append(.init(date: Date()))
        }
        objectWillChange.send()
    }
}


