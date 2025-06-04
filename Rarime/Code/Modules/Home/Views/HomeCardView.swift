import SwiftUI

struct HomeCardView<Content: View, TopContent: View, BottomContent: View>: View {
    let backgroundGradient: LinearGradient?
    let foregroundGradient: LinearGradient?
    let foregroundColor: Color
    let topIcon: ImageResource
    let bottomIcon: ImageResource
    let imageContent: () -> Content
    let title: String?
    let subtitle: String?
    let topContent: () -> TopContent?
    let bottomContent: () -> BottomContent?

    var animation: Namespace.ID

    init(
        backgroundGradient: LinearGradient? = nil,
        foregroundGradient: LinearGradient? = nil,
        foregroundColor: Color = .baseBlack,
        topIcon: ImageResource,
        bottomIcon: ImageResource,
        @ViewBuilder imageContent: @escaping () -> Content,
        title: String?,
        subtitle: String?,
        @ViewBuilder topContent: @escaping () -> TopContent? = { EmptyView() },
        @ViewBuilder bottomContent: @escaping () -> BottomContent? = { EmptyView() },
        animation: Namespace.ID
    ) {
        self.backgroundGradient = backgroundGradient
        self.foregroundGradient = foregroundGradient
        self.foregroundColor = foregroundColor
        self.topIcon = topIcon
        self.bottomIcon = bottomIcon
        self.imageContent = imageContent
        self.title = title
        self.subtitle = subtitle
        self.topContent = topContent
        self.bottomContent = bottomContent
        self.animation = animation
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            imageContent()
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            Image(topIcon)
                .iconLarge()
                .foregroundStyle(foregroundColor)
                .padding(8)
                .background(.bgComponentPrimary, in: Circle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding([.top, .leading], 20)
            VStack(alignment: .leading, spacing: 0) {
                if let topView = topContent() {
                    topView
                }
                if let title {
                    Text(title)
                        .h1()
                        .foregroundStyle(foregroundColor)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.title,
                            in: animation,
                            properties: .position
                        )
                }
                if let subtitle {
                    Text(subtitle)
                        .additional1()
                        .foregroundStyle(foregroundGradient == nil ? AnyShapeStyle(foregroundColor.opacity(0.4)) : AnyShapeStyle(foregroundGradient!))
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.subtitle,
                            in: animation,
                            properties: .position
                        )
                }
                if let bottomView = bottomContent() {
                    bottomView
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.leading, 24)
            .padding(.bottom, 32)
            Image(bottomIcon)
                .iconLarge()
                .foregroundStyle(foregroundColor)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 32)
                .padding(.trailing, 24)
        }
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(backgroundGradient == nil ? AnyShapeStyle(Color.clear) : AnyShapeStyle(backgroundGradient!))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.bgComponentPrimary, lineWidth: 1)
                )
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
        )
    }
}

#Preview {
    HomeCardView(
        backgroundGradient: Gradients.gradientFirst,
        topIcon: .rarime,
        bottomIcon: .arrowRightUpLine,
        imageContent: {
            Image(.handWithPhone)
                .resizable()
                .scaledToFit()
                .scaleEffect(0.85)
                .offset(x: 28)
                .padding(.top, 12)
        },
        title: "Your Device",
        subtitle: "Your Identity",
        bottomContent: {
            Text("* Nothing leaves this device")
                .body4()
                .foregroundStyle(.baseBlack.opacity(0.6))
                .padding(.top, 24)
        },
        animation: Namespace().wrappedValue
    )
    .padding(.horizontal, 22)
}
