import SwiftUI

struct HomeCardView<Content: View, BottomAdditionalContent: View>: View {
    let backgroundGradient: LinearGradient
    let foregroundGradient: LinearGradient?
    let topIcon: String
    let bottomIcon: String
    let imageContent: () -> Content
    let title: String?
    let subtitle: String?
    let bottomAdditionalContent: () -> BottomAdditionalContent?

    var animation: Namespace.ID

    init(
        backgroundGradient: LinearGradient,
        foregroundGradient: LinearGradient? = nil,
        topIcon: String,
        bottomIcon: String,
        @ViewBuilder imageContent: @escaping () -> Content,
        title: String?,
        subtitle: String?,
        @ViewBuilder bottomAdditionalContent: @escaping () -> BottomAdditionalContent? = { EmptyView() },
        animation: Namespace.ID
    ) {
        self.backgroundGradient = backgroundGradient
        self.foregroundGradient = foregroundGradient
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
                .square(24)
                .foregroundStyle(.baseBlack)
                .padding(8)
                .background(.bgComponentPrimary, in: Circle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding([.top, .leading], 20)
            imageContent()
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            VStack(alignment: .leading, spacing: 0) {
                if let title {
                    Text(title)
                        .h1()
                        .foregroundStyle(.baseBlack)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.title,
                            in: animation,
                            properties: .position
                        )
                }
                if let subtitle {
                    Text(subtitle)
                        .additional1()
                        .foregroundStyle(foregroundGradient == nil ? AnyShapeStyle(Color.baseBlack.opacity(0.4)) : AnyShapeStyle(foregroundGradient!))
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.subtitle,
                            in: animation,
                            properties: .position
                        )
                }
                if let bottomView = bottomAdditionalContent() {
                    bottomView
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.leading, 24)
            .padding(.bottom, 32)
            Image(bottomIcon)
                .iconLarge()
                .foregroundStyle(.baseBlack)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 32)
                .padding(.trailing, 24)
        }
        .frame(maxHeight: .infinity)
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
