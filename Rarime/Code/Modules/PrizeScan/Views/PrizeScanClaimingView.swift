import SwiftUI

struct PrizeScanClaimingView: View {
    @EnvironmentObject private var prizeScanViewModel: PrizeScanViewModel

    let onFinish: () -> Void
    let onError: () -> Void

    @State private var progress: Int = 0
    @State private var maxProgress: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            DotsLoadingView(size: 4, spacing: 3)
                .frame(width: 24, height: 24)
                .padding(12)
                .background(.baseWhite.opacity(0.2), in: Circle())
                .foregroundStyle(.baseWhite)
                .overlay(Circle().stroke(.baseWhite, lineWidth: 3))
            Text("Claiming")
                .h3()
                .foregroundStyle(.baseWhite)
                .padding(.top, 32)
            Text("Scooping up the magic bits to brew your proof")
                .body3()
                .foregroundStyle(.baseWhite.opacity(0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 260)
                .padding(.top, 12)
            LinearProgressView(
                progress: maxProgress > 0 ? Double(progress) / Double(maxProgress) : 1,
                height: 4,
                backgroundFill: AnyShapeStyle(Color.baseWhite.opacity(0.1)),
                foregroundFill: AnyShapeStyle(Color.baseWhite)
            )
            .padding(.top, 48)
            .padding(.horizontal, 24)
            Text(progress >= maxProgress ? "Processing..." : "\(progress)/\(maxProgress) MB")
                .body4()
                .foregroundStyle(.baseWhite.opacity(0.6))
                .padding(.top, 24)
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            Task {
                await claimReward()
            }
        }
    }

    func claimReward() async {
        do {
            try await prizeScanViewModel.claimReward { progress in
                self.progress = Int(progress.completedUnitCount / 1024 / 1024)
                self.maxProgress = Int(progress.totalUnitCount / 1024 / 1024)
            }
            onFinish()
        } catch {
            LoggerUtil.common.error("PrizeScan: Failed to claim reward: \(error)")
            AlertManager.shared.emitError("Failed to claim reward, try again")
            onError()
        }
    }
}

#Preview {
    PrizeScanClaimingView(onFinish: {}, onError: {})
        .background(.baseBlack)
        .environmentObject(PrizeScanViewModel())
}
