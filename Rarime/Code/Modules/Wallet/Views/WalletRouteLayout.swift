import SwiftUI

struct WalletRouteLayout<Content: View>: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let onBack: () -> Void

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 24) {
                Button(action: onBack) {
                    Image(Icons.caretLeft)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .subtitle2()
                        .foregroundColor(.textPrimary)
                    Text(description)
                        .body3()
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            content()
        }
        .padding(.top, 20)
        .background(.backgroundPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WalletRouteLayout(
        title: LocalizedStringResource("Wallet Route Title", table: "preview"),
        description: LocalizedStringResource("Lorem ipsum dolor sit amet", table: "preview"),
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
