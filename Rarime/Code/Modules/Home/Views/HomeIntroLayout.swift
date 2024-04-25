import SwiftUI

struct HomeIntroLayout<Icon: View, Content: View>: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let icon: Icon

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(spacing: 16) {
                icon
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary)
                    .foregroundStyle(.textPrimary)
                    .clipShape(Circle())
                Text(title)
                    .h6()
                    .foregroundStyle(.textPrimary)
                Text(description)
                    .body3()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300)
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            HorizontalDivider()
            content()
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeIntroLayout(
        title: LocalizedStringResource("Other passport holders", table: "preview"),
        description: LocalizedStringResource("short description text here", table: "preview"),
        icon: Image(Icons.bell).iconLarge()
    ) {
        Rectangle()
            .fill(.backgroundPrimary)
            .frame(width: .infinity, height: 200)
    }
}
