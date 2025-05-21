import SwiftUI

struct CountdownView: View {
    private let endDate: Date

    @State private var now = Date()

    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    init(endTimestamp: TimeInterval) {
        self.endDate = Date(timeIntervalSince1970: endTimestamp)
    }

    var body: some View {
        Text(timeString)
            .onReceive(timer) { tick in
                now = tick
            }
    }

    private var remainingSeconds: Int {
        max(0, Int(endDate.timeIntervalSince(now)))
    }

    private var timeString: String {
        let hrs = remainingSeconds / 3600
        let mins = (remainingSeconds % 3600) / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}

#Preview {
    VStack(spacing: 20) {
        CountdownView(endTimestamp: Date().addingTimeInterval(5).timeIntervalSince1970)
        CountdownView(endTimestamp: Date().addingTimeInterval(3600).timeIntervalSince1970)
        CountdownView(endTimestamp: Date().addingTimeInterval(-60).timeIntervalSince1970)
    }
    .padding()
}
