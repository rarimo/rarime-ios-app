import SwiftUI

struct ZkLivenessIntroView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .foregroundStyle(Gradients.gradientSixth)
                .frame(width: 400, height: 394)
                .offset(y: -300)
                .opacity(0.6)
                .blur(radius: 160)
            VStack(alignment: .leading, spacing: 40) {
                VStack(spacing: 24) {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(.bodyScanFill)
                            .square(44)
                            .padding(22)
                            .background(Gradients.gradientFirst, in: Circle())
                        Text("ZK Liveness\n(PoH Killer)")
                            .h2()
                            .foregroundStyle(.textPrimary)
                    }
                    Spacer()
                    makeListItem(
                        icon: .smartphoneLine,
                        text: String(localized: "Only your camera and device should attest to your identity.")
                    )
                    makeListItem(
                        icon: .stackLine,
                        text: String(localized: "No need for trusted third parties.")
                    )
                    makeListItem(
                        icon: .shieldCheckLine,
                        text: String(localized: "What happens here, stays here!")
                    )
                }
                AppButton(
                    text: "Let’s start",
                    action: onStart
                )
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
        }
    }

    private func makeListItem(icon: ImageResource, text: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(icon)
                .iconMedium()
                .padding(10)
                .background(Gradients.gradientFirst, in: Circle())
            Text(text)
                .body3()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    ZkLivenessIntroView {}
}
