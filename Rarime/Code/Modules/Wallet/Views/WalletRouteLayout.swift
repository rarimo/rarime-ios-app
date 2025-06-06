import SwiftUI

struct WalletRouteLayout<Content: View>: View {
    let title: String
    let description: String
    let onBack: () -> Void

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 24) {
                Button(action: onBack) {
                    Image(.caretLeft)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .subtitle4()
                        .foregroundColor(.textPrimary)
                    Text(description)
                        .body4()
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            content()
        }
        .padding(.top, 20)
        .background(.bgPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WalletRouteLayout(
        title: "Wallet Route Title",
        description: "Lorem ipsum dolor sit amet consectetur adipiscing elit",
        onBack: {}
    ) {
        VStack {
            CardContainer {
                Text(String("Wallet Route Content"))
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}
