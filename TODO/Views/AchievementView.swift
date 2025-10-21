import SwiftUI

struct AchievementView: View {
    @StateObject private var store = InMemoryStore()
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 月選択ヘッダー
                HStack {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: currentMonth))
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                // カレンダー
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // 曜日ヘッダー
                    ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                        Text(day)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                    
                    // カレンダーの日付
                    ForEach(calendarDays, id: \.self) { date in
                        if let date = date {
                            DayView(
                                date: date,
                                completionRate: completionRate(for: date),
                                isToday: calendar.isDateInToday(date)
                            )
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 40)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 統計情報
                VStack(spacing: 12) {
                    HStack {
                        Text("今月の達成率")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(monthlyCompletionRate * 100))%")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    HStack {
                        Text("連続記録")
                            .font(.headline)
                        Spacer()
                        Text("\(currentStreak)日")
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("達成率")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // カレンダーの日付配列を生成
    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        let firstDate = monthFirstWeek.start
        let lastDate = monthLastWeek.end
        let numberOfDays = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        
        return (0..<numberOfDays).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: firstDate)
        }
    }
    
    // 指定日の達成率を計算
    private func completionRate(for date: Date) -> Double {
        let tasks = store.tasks
        guard !tasks.isEmpty else { return 0.0 }
        
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        let completedTasks = tasks.filter { task in
            task.completionLogs.contains { log in
                calendar.startOfDay(for: log.date) == targetDate
            }
        }
        
        return Double(completedTasks.count) / Double(tasks.count)
    }
    
    // 今月の達成率を計算
    private var monthlyCompletionRate: Double {
        let today = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: today).day ?? 1
        
        var totalRate: Double = 0
        for i in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfMonth) {
                totalRate += completionRate(for: date)
            }
        }
        
        return totalRate / Double(daysInMonth)
    }
    
    // 現在の連続記録日数を計算
    private var currentStreak: Int {
        let tasks = store.tasks
        guard !tasks.isEmpty else { return 0 }
        
        var maxStreak = 0
        var currentDate = Date()
        var currentStreak = 0
        
        // 過去30日分をチェック
        for _ in 0..<30 {
            let rate = completionRate(for: currentDate)
            if rate >= 0.5 { // 50%以上完了していれば連続記録としてカウント
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return maxStreak
    }
}

struct DayView: View {
    let date: Date
    let completionRate: Double
    let isToday: Bool
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayFormatter.string(from: date))
                .font(.caption)
                .foregroundStyle(isToday ? .white : .primary)
            
            // 達成率を色で表現
            Circle()
                .fill(completionColor)
                .frame(width: 20, height: 20)
        }
        .frame(height: 40)
        .background(
            isToday ? Color.blue : Color.clear,
            in: Circle()
        )
    }
    
    private var completionColor: Color {
        if completionRate >= 0.8 {
            return .green
        } else if completionRate >= 0.5 {
            return .yellow
        } else if completionRate > 0 {
            return .orange
        } else {
            return .gray.opacity(0.3)
        }
    }
}

struct AchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
    }
}
