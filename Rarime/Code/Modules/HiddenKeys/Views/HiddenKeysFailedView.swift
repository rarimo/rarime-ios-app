import SwiftUI

struct HiddenKeysFailedView: View {
    @EnvironmentObject private var hiddenKeysViewModel: HiddenKeysViewModel

    let onScanAgain: () -> Void

    private var tip: String {
        hiddenKeysViewModel.user?.celebrity.hint ?? ""
    }

    private var totalAttemptsLeft: Int {
        (hiddenKeysViewModel.user?.attemptsLeft ?? 0) + (hiddenKeysViewModel.user?.extraAttemptsLeft ?? 0)
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
                Text("Swing and a miss, this face isn’t hiding the key. Keep scanning!")
                    .body3()
                    .foregroundStyle(.baseWhite.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 260)
                    .padding(.top, 12)
            }
            VStack(spacing: 20) {
                Spacer()
                Text("Different photos of the same person return the same result, try scanning a new face")
                    .body4()
                    .foregroundStyle(.baseWhite.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
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
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

#Preview {
    HiddenKeysFailedView(onScanAgain: {})
        .background(.baseBlack)
        .environmentObject(HiddenKeysViewModel())
}
