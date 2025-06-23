import MessageUI
import SwiftUI

struct PassportChipErrorView: View {
    let onClose: () -> Void

    @State private var isSending = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(.rarime)
                .square(128)
                .foregroundStyle(.textPrimary)
            VStack(spacing: 8) {
                Text("We’re working on a fix")
                    .h3()
                    .foregroundStyle(.textPrimary)
                Text("Some passports have a problem with chip scans")
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 300)
            .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: 12) {
                AppButton(
                    text: "Get in touch",
                    rightIcon: .arrowRight,
                    action: {
                        if MFMailComposeViewController.canSendMail() {
                            isSending = true
                        } else {
                            UIApplication.shared.open(
                                URL(string: "mailto:\(ConfigManager.shared.general.feedbackEmail)?subject=Passport Chip Error")!
                            )
                            onClose()
                        }
                    }
                )
                .controlSize(.large)
                AppButton(
                    variant: .quartenary,
                    text: "Cancel",
                    action: onClose
                )
                .controlSize(.large)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgPure)
        .dynamicSheet(isPresented: $isSending, fullScreen: true) {
            FeedbackMailView(isShowing: $isSending)
        }
        .onChange(of: isSending) { isSending in
            if !isSending {
                onClose()
            }
        }
    }
}

#Preview {
    PassportChipErrorView(onClose: {})
}
