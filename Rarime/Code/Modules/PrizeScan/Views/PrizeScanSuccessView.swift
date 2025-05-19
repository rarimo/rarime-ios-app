import ConfettiSwiftUI
import SwiftUI

struct PrizeScanSuccessView: View {
    let onClaim: () -> Void

    @State private var confettiTrigger = 0

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()
                VStack(spacing: 0) {
                    Image(.checkLine)
                        .square(24)
                        .padding(12)
                        .background(.baseWhite.opacity(0.2), in: Circle())
                        .foregroundStyle(.baseWhite)
                        .overlay(Circle().stroke(.baseWhite, lineWidth: 3))
                    Text("Congrats!")
                        .h3()
                        .foregroundStyle(.baseWhite)
                        .padding(.top, 32)
                    Text("You've found the hidden keys")
                        .body3()
                        .foregroundStyle(.baseWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 260)
                        .padding(.top, 12)
                }
                HorizontalDivider(color: .baseWhite.opacity(0.05))
                VStack(spacing: 8) {
                    Text("Your prize")
                        .subtitle6()
                        .foregroundStyle(.baseWhite.opacity(0.6))
                    HStack(spacing: 10) {
                        Text(verbatim: PRIZE_SCAN_ETH_REWARD.formatted())
                            .h3()
                            .foregroundStyle(.baseWhite)
                        Image(.ethereum)
                            .iconMedium()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(.baseWhite.opacity(0.05), in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 32)
                Spacer()
                Button(action: onClaim) {
                    Text("Claim")
                        .foregroundStyle(.baseBlack)
                        .buttonLarge()
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .background(.baseWhite, in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .padding(.horizontal, 32)
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 300,
            colors: [
                .purpleLighter,
                .purpleLight,
                .purpleMain,
                .purpleDark
            ],
            rainHeight: UIScreen.main.bounds.height,
            openingAngle: Angle.degrees(0),
            closingAngle: Angle.degrees(180),
            radius: 480
        )
        .onAppear {
            confettiTrigger += 1
        }
    }
}

#Preview {
    PrizeScanSuccessView(onClaim: {})
        .background(.baseBlack)
}
