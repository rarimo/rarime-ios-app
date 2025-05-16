import SwiftUI

struct PrizeScanClaimingView: View {
    let onFinish: () -> Void
    let onError: () -> Void

    let MAX_PROGRESS: Int = 150

    @State private var progress: Int = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            DotsLoadingView(size: 4, spacing: 3)
                .frame(width: 24, height: 24)
                .padding(12)
                .background(.baseWhite.opacity(0.2), in: Circle())
                .foregroundStyle(.baseWhite)
                .overlay(Circle().stroke(.baseWhite, lineWidth: 3))
            Image(.dotsThreeOutline)
                .square(24)
            Text("Claiming")
                .h3()
                .foregroundStyle(.baseWhite)
                .padding(.top, 32)
            Text("Downloading some data for the proof generation and send the proof on chain")
                .body3()
                .foregroundStyle(.baseWhite.opacity(0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 260)
                .padding(.top, 12)
            LinearProgressView(
                progress: Double(progress) / Double(MAX_PROGRESS),
                height: 4,
                backgroundFill: AnyShapeStyle(Color.baseWhite.opacity(0.1)),
                foregroundFill: AnyShapeStyle(Color.baseWhite)
            )
            .padding(.top, 48)
            .padding(.horizontal, 24)
            Text("\(progress)/\(MAX_PROGRESS) MB")
                .body4()
                .foregroundStyle(.baseWhite.opacity(0.6))
                .padding(.top, 24)
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            startTimer()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if progress < MAX_PROGRESS {
                progress += 1
            } else {
                timer?.invalidate()
                onFinish()
            }
        }
    }
}

#Preview {
    PrizeScanClaimingView(onFinish: {}, onError: {})
        .background(.baseBlack)
}
