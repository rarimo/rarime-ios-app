import ConfettiSwiftUI
import SwiftUI

struct LikenessSuccessView: View {
    let onClose: () -> Void

    @State private var confettiTrigger = 0

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 32) {
                Image(.checkLine)
                    .iconLarge()
                    .foregroundStyle(.baseWhite)
                    .padding(12)
                    .background(.baseWhite.opacity(0.2), in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.baseWhite, lineWidth: 3)
                    )
                VStack(spacing: 12) {
                    Text("Congrats!")
                        .h3()
                        .foregroundStyle(.baseWhite)
                    Text("You've successfully set your likeness rule")
                        .body3()
                        .foregroundStyle(.baseWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 260)
                }
                VStack(spacing: 8) {
                    Spacer()
                    Button(action: onClose) {
                        Text("Close")
                            .buttonLarge()
                            .foregroundStyle(.baseWhite)
                            .padding(18)
                            .frame(maxWidth: .infinity, maxHeight: 56)
                            .background(.baseWhite.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                    }
                    ShareLink(
                        item: ConfigManager.shared.general.webAppURL.appendingPathComponent("download-app"),
                        subject: Text("My face, my rules ✅"),
                        message: Text("I just set a personal AI-usage rule for my digital likeness in rariMe. Take charge of yours in under a minute—privacy starts with you.")
                    ) {
                        Text("Share")
                            .buttonLarge()
                            .foregroundStyle(.baseBlack)
                            .padding(18)
                            .frame(maxWidth: .infinity, maxHeight: 56)
                            .background(.baseWhite, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .padding(.top, 240)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 300,
            colors: [
                .purpleLighter,
                .purpleLight,
                .purpleMain,
                .purpleDark
            ],
            rainHeight: 1000,
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
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            LikenessSuccessView(onClose: {})
                .background(.baseBlack)
        }
}
