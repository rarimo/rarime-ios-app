import SwiftUI

private let privateKey = "d4f1dc5332e5f0263746a31d3563e42ad8bef24a8989d8b0a5ad71f8d5de28a6"

struct ExportKeysView: View {
    let onBack: () -> Void

    @State private var isCopied = false

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Export Keys"),
            onBack: onBack
        ) {
            CardContainer {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Private Key")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text(privateKey)
                        .body3()
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(.componentPrimary)
                        .cornerRadius(8)
                    copyButton
                    HorizontalDivider()
                    InfoAlert(text: "Please store the private key safely and do not share it with anyone. If you lose this key, you will not be able to recover the account and will lose access forever.") {}
                }
            }
        }
    }

    var copyButton: some View {
        HStack {
            Spacer()
            Image(isCopied ? Icons.check : Icons.copySimple).iconMedium()
            Text(isCopied ? "Copied" : "Copy to clipboard").buttonMedium()
            Spacer()
        }
        .foregroundStyle(.textPrimary)
        .onTapGesture {
            if isCopied { return }

            UIPasteboard.general.string = privateKey
            isCopied = true
            FeedbackGenerator.shared.impact(.medium)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCopied = false
            }
        }
    }
}

#Preview {
    ExportKeysView(onBack: {})
}
