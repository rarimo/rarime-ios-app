import SwiftUI

struct CongratsView: View {
    @Binding var open: Bool
    var isClaimed: Bool

    var body: some View {
        ZStack {
            if open {
                ZStack {
                    ZStack(alignment: .top) {
                        Image(Images.confetti)
                            .resizable()
                            .frame(width: 220, height: 160)
                        VStack(spacing: 20) {
                            if isClaimed {
                                Image(Images.rewardCoin).square(100)
                            } else {
                                Image(Icons.check)
                                    .square(24)
                                    .foregroundStyle(.backgroundPure)
                                    .padding(28)
                                    .background(.successMain)
                                    .clipShape(Circle())
                            }
                            VStack(spacing: 8) {
                                Text(isClaimed ? "Congrats!" : "You’ve joined the waitlist")
                                    .h6()
                                    .foregroundStyle(.textPrimary)
                                Text(isClaimed ? "You’ve received \(RARIMO_AIRDROP_REWARD) RMO tokens" : "We will notify when you become eligible")
                                    .body2()
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.textSecondary)
                            }
                            HorizontalDivider()
                            AppButton(text: isClaimed ? "Thanks!" : "Okay", action: { open = false })
                                .controlSize(.large)
                        }
                    }
                    .padding(20)
                    .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.baseBlack.opacity(0.1))
            }
        }
        .animation(.easeOut, value: open)
    }
}

#Preview {
    CongratsView(open: .constant(true), isClaimed: true)
}
