import SwiftUI

struct ExportKeysView: View {
    @EnvironmentObject private var userManager: UserManager
    let onBack: () -> Void

    @State private var isCopied = false

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Export Keys"),
            onBack: onBack
        ) {
            CardContainer {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = userManager.user {
                        Text(user.secretKey.hex)
                            .body3()
                            .foregroundStyle(.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(.componentPrimary)
                            .cornerRadius(8)
                    }
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

            guard let user = userManager.user else { return }

            UIPasteboard.general.string = user.secretKey.hex
            isCopied = true
            FeedbackGenerator.shared.impact(.medium)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCopied = false
            }
        }
    }
}

#Preview {
    @StateObject var userManager = UserManager.shared

    return ExportKeysView(onBack: {})
        .environmentObject(userManager)
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
