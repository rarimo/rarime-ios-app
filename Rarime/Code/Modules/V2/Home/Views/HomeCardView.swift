import SwiftUI

struct HomeCardView<Content: View, BottomActions: View>: View {
    let backgroundGradient: LinearGradient
    let title: String
    let subtitle: String
    let icon: String
    let imageContent: () -> Content
    let bottomActions: () -> BottomActions
    
    init(
        backgroundGradient: LinearGradient,
        title: String,
        subtitle: String,
        icon: String,
        @ViewBuilder imageContent: @escaping () -> Content,
        @ViewBuilder bottomActions: @escaping () -> BottomActions
    ) {
        self.backgroundGradient = backgroundGradient
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.imageContent = imageContent
        self.bottomActions = bottomActions
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            imageContent()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .h4()
                    .fontWeight(.medium)
                    .foregroundStyle(.textPrimary)
                Text(subtitle)
                    .h3()
                    .fontWeight(.semibold)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.leading, 24)
            .padding(.top, 32)
            Image(icon)
                .iconLarge()
                .foregroundStyle(Color.baseBlack.opacity(0.2))
                .padding(8)
                .background(Color.baseBlack.opacity(0.03))
                .cornerRadius(100)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 12)
                .padding(.top, 12)
            bottomActions()
                .frame(maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 500)
        .frame(maxWidth: .infinity)
        .background(backgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

#Preview {
    HomeCardView(
        backgroundGradient: Gradients.gradientFirst,
        title: "Your Device",
        subtitle: "Your Identity",
        icon: Icons.rarime,
        imageContent: {
            Image(Images.handWithPhone)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .scaleEffect(0.9)
                .offset(x: 30, y: 20)
        },
        bottomActions: {
            Text("* Nothing leaves this device")
                .body3()
                .foregroundStyle(.textPrimary)
                .padding(.leading, 24)
                .padding(.bottom, 32)
        }
    )
    .padding(.horizontal, 22)
}
