import SwiftUI

struct IdentityIntroView: View {
    let onClose: () -> Void
    let onStart: () -> Void
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            AppIconButton(icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .trailing], 20)
            Image(Images.handWithPhone)
                .resizable()
                .scaledToFit()
                .scaleEffect(0.9, anchor: .trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your Device")
                        .h1()
                        .foregroundStyle(.baseBlack)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.title,
                            in: animation,
                            properties: .position
                        )
                    Text("Your Identity")
                        .additional1()
                        .foregroundStyle(.baseBlack.opacity(0.4))
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.subtitle,
                            in: animation,
                            properties: .position
                        )
                }
                Text("This app is where you privately store your digital identities, enabling you to go incognito across the web.")
                    .body3()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                AppButton(variant: .secondary, text: "Let’s Start", action: onStart)
                    .controlSize(.large)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding([.top, .horizontal], 24)
            .padding(.bottom, 8)
        }
        .background(
            Gradients.gradientFirst
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    IdentityIntroView(onClose: {}, onStart: {}, animation: Namespace().wrappedValue)
}
