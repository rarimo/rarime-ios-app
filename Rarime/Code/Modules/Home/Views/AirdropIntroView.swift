import SwiftUI

struct AirdropIntroView: View {
    @EnvironmentObject private var configManager: ConfigManager

    let onStart: () -> Void
    @State private var termsChecked = false

    private var termsURL: String {
        configManager.termsOfUseURL.absoluteString
    }

    private var privacyURL: String {
        configManager.privacyPolicyURL.absoluteString
    }

    private var airdropTermsURL: String {
        configManager.termsOfUseURL.absoluteString
    }

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Programmable Airdrop"),
                description: String(localized: "The beta launch is focused on distributing tokens to Ukrainian citizens"),
                icon: Text(String("🇺🇦")).h4()
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What’s that?")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("This airdrop is part of a humanitarian effort to help direct funds towards Ukraine.\n\nIt showcases Rarimo’s identity infrastructure. and how it can be used by projects and organizations to directly reach civilians.")
                        .body3()
                        .foregroundStyle(.textPrimary)
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
