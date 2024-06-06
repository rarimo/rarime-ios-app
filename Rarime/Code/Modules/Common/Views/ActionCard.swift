import SwiftUI

struct ActionCard<Icon: View>: View {
    let title: String
    let description: String
    let transparent: Bool
    @ViewBuilder let icon: () -> Icon

    init(
        title: String,
        description: String,
        transparent: Bool = false,
        @ViewBuilder icon: @escaping () -> Icon = { EmptyView() }
    ) {
        self.title = title
        self.description = description
        self.transparent = transparent
        self.icon = icon
    }

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                icon()
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text(description)
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer()
            Image(Icons.caretRight)
                .iconSmall()
                .padding(4)
                .background(.primaryMain)
                .clipShape(Circle())
                .foregroundStyle(.baseBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(transparent ? .clear : .backgroundOpacity, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.componentPrimary, lineWidth: transparent ? 1 : 0)
        )
    }
}

#Preview {
    VStack {
        ActionCard(
            title: "Scan QR code",
            description: "Scan a QR code to get access"
        )
        ActionCard(
            title: "Card with icon",
            description: "Test action card with icon",
            icon: { Image(Icons.bell).iconMedium() }
        )
        ActionCard(
            title: "Transparent card",
            description: "Test action card",
            transparent: true
        )
    }
    .padding(12)
    .frame(maxHeight: .infinity)
    .background(.backgroundPrimary)
}
