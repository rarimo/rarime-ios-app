import SwiftUI

struct HomeIntroLayout<Icon: View, Subheader: View, Content: View>: View {
    let title: String
    let description: String?
    let icon: Icon

    @ViewBuilder var subheader: () -> Subheader
    @ViewBuilder var content: () -> Content

    init(
        title: String,
        description: String? = nil,
        icon: Icon,
        @ViewBuilder subheader: @escaping () -> Subheader = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.subheader = subheader
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(spacing: 16) {
                icon
                Text(title)
                    .h6()
                    .foregroundStyle(.textPrimary)
                if let description {
                    Text(description)
                        .body3()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 300)
                        .foregroundStyle(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            subheader()
            HorizontalDivider()
            content()
        }
        .padding(.top, 40)
        .padding(.horizontal, 24)
    }
}

#Preview {
    HomeIntroLayout(
        title: "Other passport holders",
        description: "short description text here",
        icon: Image(Icons.bell).iconLarge()
    ) {
        Rectangle()
            .fill(.backgroundPrimary)
            .frame(width: .infinity, height: 200)
    }
}
