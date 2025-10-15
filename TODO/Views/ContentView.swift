import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checklist")
                    .font(.system(size: 48))
                Text("Routine TODO")
                    .font(.title.bold())
                Text("毎日のルーティンにフォーカスして、決まった時間に実行・記録")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                NavigationLink("今日のルーティンへ") {
                    DailyView()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("ホーム")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


