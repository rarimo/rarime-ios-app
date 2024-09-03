import Alamofire
import SwiftUI

struct CreateIdentityIntroView: View {
    let onStart: () -> Void

    @State private var termsChecked = false

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Add a Document"),
                description: String(localized: "Create your digital identity"),
                icon: Image(Images.rewardCoin).square(110)
            ) {
                Text("Identity creation happens via a scan of your biometric passport.\n\nYour data never leaves the device or is shared with any third party. Proof of citizenship is generated locally using Zero-Knowledge technology.")
                    .body3()
                    .foregroundStyle(.textPrimary)
                InfoAlert(text: "If you lose access to the device or private keys, you won’t be able to claim future rewards using the same passport") {}
            }
            Spacer()
            HorizontalDivider()
            AirdropCheckboxView(checked: $termsChecked)
                .padding(.horizontal, 20)
            AppButton(text: "Continue", action: onStart)
                .controlSize(.large)
                .disabled(!termsChecked)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    return CreateIdentityIntroView(onStart: {})
        .environmentObject(ConfigManager())
        .onAppear {
            try? userManager.createNewUser()
        }
}
