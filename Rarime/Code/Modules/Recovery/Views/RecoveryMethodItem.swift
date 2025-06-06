import SwiftUI

struct RecoveryMethodItem<Content: View>: View {
    let icon: ImageResource
    let title: String
    let description: String
    let isRecommended: Bool
    let isDisabled: Bool
    var content: () -> Content

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if isRecommended {
                Text("Recommended")
                    .overline3()
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .padding(.trailing, 4)
                    .foregroundStyle(.baseWhite)
                    .background(.warningMain)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 8,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
            }
            HStack(spacing: 20) {
                Image(icon)
                    .iconMedium()
                    .foregroundStyle(isDisabled ? .textPlaceholder : .textPrimary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .subtitle5()
                        .foregroundStyle(isDisabled ? .textSecondary : .textPrimary)
                    Text(description)
                        .body5()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                content()
            }
            .padding(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isRecommended ? .warningMain : .bgComponentPrimary, lineWidth: 1)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    RecoveryMethodItem(
        icon: .key2Line,
        title: "Private Key",
        description: "Use your private key to recover your account",
        isRecommended: true,
        isDisabled: false
    ) {
        AppToggle(isOn: .constant(false))
    }
}
