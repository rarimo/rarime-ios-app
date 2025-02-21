import SwiftUI

struct HomeCardView<Content: View, BottomAdditionalContent: View>: View {
    let backgroundGradient: LinearGradient
    let topIcon: String
    let bottomIcon: String
    let imageContent: () -> Content
    let title: String
    let subtitle: String
    let bottomAdditionalContent: () -> BottomAdditionalContent?
    
    var animation: Namespace.ID
    
    init(
        backgroundGradient: LinearGradient,
        topIcon: String,
        bottomIcon: String,
        @ViewBuilder imageContent: @escaping () -> Content,
        title: String,
        subtitle: String,
        @ViewBuilder bottomAdditionalContent: @escaping () -> BottomAdditionalContent?,
        animation: Namespace.ID
    ) {
        self.backgroundGradient = backgroundGradient
        self.topIcon = topIcon
        self.bottomIcon = bottomIcon
        self.imageContent = imageContent
        self.title = title
        self.subtitle = subtitle
        self.bottomAdditionalContent = bottomAdditionalContent
        self.animation = animation
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Image(topIcon)
                .square(32)
                .foregroundStyle(.baseBlack.opacity(0.5))
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.trailing, 20)
                .padding(.top, 20)
            imageContent()
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .h2()
                    .foregroundStyle(.baseBlack)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.title,
                        in: animation,
                        properties: .position
                    )
                Text(subtitle)
                    .additional2()
                    .foregroundStyle(.baseBlack.opacity(0.4))
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.subtitle,
                        in: animation,
                        properties: .position
                    )
                if let bottomView = bottomAdditionalContent() {
                    bottomView
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.leading, 24)
            .padding(.bottom, 24)
            Image(bottomIcon)
                .iconLarge()
                .foregroundStyle(.baseBlack)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 24)
                .padding(.trailing, 24)
        }
        .frame(height: 500)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(backgroundGradient)
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
        )
    }
}

#Preview {
    HomeCardView(
        backgroundGradient: Gradients.gradientFirst,
        topIcon: Icons.rarime,
        bottomIcon: Icons.arrowRightUpLine,
        imageContent: {
            Image(Images.handWithPhone)
                .resizable()
                .scaledToFit()
                .scaleEffect(0.85)
                .offset(x: 28)
                .padding(.top, 12)
        },
        title: "Your Device",
        subtitle: "Your Identity",
        bottomAdditionalContent: {
            Text("* Nothing leaves this device")
                .body4()
                .foregroundStyle(.baseBlack.opacity(0.6))
                .padding(.top, 24)
        },
        animation: Namespace().wrappedValue
    )
    .padding(.horizontal, 22)
}
