import SwiftUI

struct HomeCardView<Content: View, TopContent: View, BottomContent: View>: View {
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
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(.bgComponentPrimary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

#Preview {
    HomeCardView(
        foregroundGradient: Gradients.darkerGreenText,
        foregroundColor: .invertedDark,
        topIcon: .rarime,
        bottomIcon: .arrowRightUpLine,
        imageContent: {
            Image(.earnBg)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 32))
        },
        title: "Earn",
        subtitle: "RMO",
        bottomContent: {
            Text("Complete various tasks and get rewarded with Rarimo tokens")
                .body4()
                .foregroundStyle(.textSecondary)
                .frame(maxWidth: 220, alignment: .leading)
                .padding(.top, 12)
        },
        animation: Namespace().wrappedValue
    )
    .padding(.horizontal, 22)
}
