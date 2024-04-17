import SwiftUI

struct ActionCard: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    var body: some View {
        CardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text(description)
                        .body3()
                        .foregroundStyle(.textSecondary)
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
    ActionCard(
        title: LocalizedStringResource("Scan QR code", table: "preview"),
        description: LocalizedStringResource("Scan a QR code to get access to the app", table: "preview")
    )
}
