import SwiftUI

struct AirdropIntroView: View {
    @EnvironmentObject private var configManager: ConfigManager

    let onStart: () -> Void
    @State private var termsChecked = false

    private var termsURL: String {
        configManager.general.termsOfUseURL.absoluteString
    }

    private var privacyURL: String {
        configManager.general.privacyPolicyURL.absoluteString
    }

    private var airdropTermsURL: String {
        configManager.general.termsOfUseURL.absoluteString
    }

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: "Programable Airdrop",
                description: "Beta launch is focused on distributing tokens to Ukrainian identity holders",
                icon: Text("🇺🇦").h4()
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    makeListItem("1.", "Personal data never leaves the device")
                    makeListItem("2.", "Full privacy via Zero Knowledge Proofs")
                    makeListItem("3.", "Get rewarded with RMO tokens")
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("What is this?")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it h")
                        .body3()
                        .foregroundStyle(.textPrimary)
                    Text("Full functional available on: \(Text("July").fontWeight(.semibold))")
                        .body3()
                        .foregroundStyle(.warningMain)
                }
            }
            Spacer()
            HorizontalDivider()
            HStack(alignment: .top, spacing: 8) {
                AppCheckbox(checked: $termsChecked)
                (
                    Text("By checking this box, you are agreeing to ") +
                        Text(.init("[RariMe General Terms & Conditions](\(termsURL))")).underline() +
                        Text(", ") +
                        Text(.init("[RariMe Privacy Notice](\(privacyURL))")).underline() +
                        Text(" and ") +
                        Text(.init("[Rarimo Airdrop Program Terms & Conditions](\(airdropTermsURL))")).underline()
                )
                .body4()
                .tint(.textSecondary)
                .foregroundStyle(.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            AppButton(text: "Continue", action: onStart)
                .controlSize(.large)
                .disabled(!termsChecked)
                .padding(.horizontal, 20)
        }
    }

    private func makeListItem(_ number: String, _ text: LocalizedStringResource) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .subtitle4()
                .frame(width: 14)
            Text(text).body3()
        }
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    AirdropIntroView(onStart: {})
        .environmentObject(ConfigManager())
}
