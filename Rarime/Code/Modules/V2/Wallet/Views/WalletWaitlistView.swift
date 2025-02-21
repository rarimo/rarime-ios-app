import SwiftUI

struct WalletWaitlistView: View {
    let onClose: () -> Void
    let onJoin: () -> Void
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            AppIconButton(icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .trailing], 20)
            Image(Images.seedPhraseShred)
                .resizable()
                .scaledToFit()
                .padding(.top, 24)
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("An Unforgettable")
                        .h1()
                        .foregroundStyle(.baseBlack)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.title,
                            in: animation,
                            properties: .position
                        )
                    Text("Wallet")
                        .additional1()
                        .foregroundStyle(.baseBlack.opacity(0.4))
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.subtitle,
                            in: animation,
                            properties: .position
                        )
                }
                Text("Say goodbye to seed phrases! ZK Face Wallet leverages cutting-edge zero-knowledge (ZK) cryptography and biometric authentication to give you a seamless, secure, and self-sovereign crypto experience.")
                    .body3()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                VStack(alignment: .center, spacing: 16) {
                    AppButton(variant: .secondary, text: "Join Waitlist", action: onJoin)
                        .controlSize(.large)
                    Text("49,421 other already joined")
                        .body5()
                        .foregroundStyle(.baseBlack.opacity(0.5))
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding([.top, .horizontal], 24)
            .padding(.bottom, 8)
        }
        .background(
            Gradients.gradientFourth
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    WalletWaitlistView(onClose: {}, onJoin: {}, animation: Namespace().wrappedValue)
}
