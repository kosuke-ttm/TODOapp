import SwiftUI

struct DailyView: View {
    @StateObject private var store = InMemoryStore()
    @State private var isPresentingAdd = false
    @State private var newTitle: String = ""
    @State private var selectedHour: Int = 8
    @State private var selectedMinute: Int = 0
    @State private var hasNotification: Bool = false

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
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    AchievementView()
                } label: {
                    Image(systemName: "chart.bar.fill")
                }
            }
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
                    
                    Section(header: Text("通知設定")) {
                        Toggle("通知を有効にする", isOn: $hasNotification)
                        
                        if hasNotification {
                            HStack {
                                Text("時間")
                                Spacer()
                                Picker("時間", selection: $selectedHour) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        Text(String(format: "%02d", hour)).tag(hour)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 60)
                                
                                Text(":")
                                
                                Picker("分", selection: $selectedMinute) {
                                    ForEach(0..<60, id: \.self) { minute in
                                        Text(String(format: "%02d", minute)).tag(minute)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 60)
                            }
                        }
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
                            
                            let notification = hasNotification ? 
                                NotificationSetting(hour: selectedHour, minute: selectedMinute, weekdays: Set(1...7)) : nil
                            
                            store.addTask(title: title, notification: notification)
                            newTitle = ""
                            hasNotification = false
                            selectedHour = 8
                            selectedMinute = 0
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


