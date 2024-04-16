import SwiftUI

struct HomeIntroLayoutView<Icon: View, Content: View>: View {
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
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
            HorizontalDivider()
            content()
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeIntroLayoutView(
        title: LocalizedStringResource("Other passport holders", table: "preview"),
        description: LocalizedStringResource("short description text here", table: "preview"),
        icon: Image(Icons.bell).iconLarge()
    ) {
        Rectangle()
            .fill(.backgroundPrimary)
            .frame(width: .infinity, height: 200)
    }
}
