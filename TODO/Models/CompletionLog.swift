import Foundation

struct CompletionLog: Identifiable, Hashable {
    let id: UUID
    let date: Date

    init(id: UUID = UUID(), date: Date) {
        self.id = id
        self.date = date
    }
}


