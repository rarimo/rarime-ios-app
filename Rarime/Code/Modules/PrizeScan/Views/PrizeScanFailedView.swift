import SwiftUI

struct PrizeScanFailedView: View {
    @EnvironmentObject private var prizeScanViewModel: PrizeScanViewModel

    let onScanAgain: () -> Void

    private var tip: String {
        prizeScanViewModel.user?.celebrity?.hint ?? ""
    }

    private var totalAttemptsLeft: Int {
        (prizeScanViewModel.user?.attemptsLeft ?? 0) + (prizeScanViewModel.user?.extraAttemptsLeft ?? 0)
    }

    private var hasAttempts: Bool {
        totalAttemptsLeft > 0
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image(.uncertainFace)
                    .square(48)
                    .foregroundStyle(.baseWhite)
                    .background(.baseWhite.opacity(0.2), in: Circle())
                Text("Wrong face...")
                    .h3()
                    .foregroundStyle(.baseWhite)
                    .padding(.top, 32)
                Text("The face you scanned is not the correct one. You can try again.")
                    .body3()
                    .foregroundStyle(.baseWhite.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 260)
                    .padding(.top, 12)
            }
            VStack(spacing: 20) {
                Spacer()
                if !tip.isEmpty {
                    Text(tip)
                        .body4()
                        .foregroundStyle(.baseWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button(action: onScanAgain) {
                    Text(hasAttempts ? "Scan again" : "Try again later")
                        .foregroundStyle(.baseWhite.opacity(hasAttempts ? 1 : 0.6))
                        .buttonLarge()
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .background(.baseWhite.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                }
                .disabled(!hasAttempts)
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    PrizeScanFailedView(onScanAgain: {})
        .background(.baseBlack)
        .environmentObject(PrizeScanViewModel())
}
