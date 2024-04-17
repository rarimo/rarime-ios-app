import SwiftUI

struct CongratsModalView: View {
    @Binding var open: Bool
    var isClaimed: Bool

    var body: some View {
        ZStack {
            if open {
                ZStack {
                    CardContainer {
                        ZStack(alignment: .top) {
                            Image("Confetti")
                                .resizable()
                                .frame(width: 220, height: 160)
                            VStack(spacing: 20) {
                                if isClaimed {
                                    Image("RewardCoin").square(100)
                                } else {
                                    Image(Icons.check)
                                        .square(24)
                                        .foregroundStyle(.baseWhite)
                                        .padding(28)
                                        .background(.successMain)
                                        .clipShape(Circle())
                                }
                                VStack(spacing: 8) {
                                    Text(isClaimed ? "Congrats!" : "You’ve joined the waitlist")
                                        .h6()
                                        .foregroundStyle(.textPrimary)
                                    Text(isClaimed ? "You’ve received 3 RMO tokens" : "We will notify when you become eligible")
                                        .body2()
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.textSecondary)
                                }
                                HorizontalDivider()
                                AppButton(text: isClaimed ? "Thanks!" : "Okay", action: { open = false })
                                    .controlSize(.large)
                            }
                        }
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.baseBlack.opacity(0.1))
            }
        }
        .animation(.easeOut, value: open)
    }
}

#Preview {
    CongratsModalView(open: .constant(true), isClaimed: true)
}
