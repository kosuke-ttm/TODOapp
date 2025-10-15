import SwiftUI

struct DailyView: View {
    @StateObject private var store = InMemoryStore()
    @State private var isPresentingAdd = false
    @State private var newTitle: String = ""

    var body: some View {
        List {
            Section(header: Text("今日のルーティン")) {
                ForEach(store.todayTasks) { task in
                    HStack(spacing: 12) {
                        Button {
                            store.toggleComplete(for: task)
                        } label: {
                            Image(systemName: task.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isCompletedToday ? .green : .secondary)
                                .font(.title3)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.body)
                            if let time = task.notifyTimeString {
                                Text("通知: \(time)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if task.streakCount > 0 {
                            Text("\(task.streakCount)日")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.15), in: Capsule())
                        }
                    }
                }
            }
        }
        .animation(.default, value: store.todayTasks)
        .navigationTitle("今日")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            NavigationStack {
                Form {
                    Section(header: Text("タイトル")) {
                        TextField("例: 歯みがき", text: $newTitle)
                            .submitLabel(.done)
                    }
                }
                .navigationTitle("TODOを追加")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { isPresentingAdd = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("追加") {
                            let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !title.isEmpty else { return }
                            store.addTask(title: title)
                            newTitle = ""
                            isPresentingAdd = false
                        }
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { DailyView() }
    }
}


