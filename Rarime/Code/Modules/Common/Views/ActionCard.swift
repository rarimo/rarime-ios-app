import SwiftUI

struct ActionCard<Icon: View>: View {
    let title: String
    let description: String
    @ViewBuilder let icon: () -> Icon

    init(
        title: String,
        description: String,
        @ViewBuilder icon: @escaping () -> Icon = { EmptyView() }
    ) {
        self.title = title
        self.description = description
        self.icon = icon
    }

    var body: some View {
        CardContainer {
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
        }
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
            description: "Test action card with icon"
        ) {
            Image(Icons.bell).iconMedium()
        }
    }
    .padding(12)
    .frame(maxHeight: .infinity)
    .background(.backgroundPrimary)
}
