import MessageUI
import SwiftUI

struct PassportChipErrorView: View {
    let onClose: () -> Void

    @State private var isSending = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(Images.gears)
                .resizable()
                .scaledToFit()
                .frame(height: 136)
            VStack(spacing: 16) {
                Text("We’re working on a fix")
                    .subtitle2()
                    .foregroundStyle(.textPrimary)
                Text("Some passports have a problem with chip scans")
                    .body3()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 250)
            Spacer()
            VStack(spacing: 12) {
                AppButton(
                    text: "Get in touch",
                    rightIcon: Icons.arrowRight,
                    action: {
                        if MFMailComposeViewController.canSendMail() {
                            isSending = true
                        } else {
                            UIApplication.shared.open(
                                URL(string: "mailto:\(ConfigManager.shared.feedback.feedbackEmail)?subject=Passport Chip Error")!
                            )
                            onClose()
                        }
                    }
                )
                .controlSize(.large)
                AppButton(
                    variant: .tertiary,
                    text: "Cancel",
                    action: onClose
                )
                .controlSize(.large)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPure)
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
