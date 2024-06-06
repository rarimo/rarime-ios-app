import SwiftUI

struct RewardsIntroView: View {
    let onStart: () -> Void
    @State private var termsChecked = false

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Join Rewards Program"),
                description: String(localized: "Check your eligibility"),
                icon: Image(Images.rewardCoin).square(110)
            ) {
                Text("Checking eligibility happens via a scan of your biometric passport.\n\nYour data never leaves the device or is shared with any third party. Proof of citizenship is generated locally using Zero-Knowledge technology.")
                    .body3()
                    .foregroundStyle(.textPrimary)
                InfoAlert(text: "If you lose access to the device or private keys, you won’t be able to claim future rewards using the same passport") {}
            }
            Spacer()
            HorizontalDivider()
            AirdropCheckboxView(checked: $termsChecked)
                .padding(.horizontal, 20)
            AppButton(text: "Check eligibility", action: onStart)
                .controlSize(.large)
                .disabled(!termsChecked)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    RewardsIntroView(onStart: {})
        .environmentObject(ConfigManager())
}
