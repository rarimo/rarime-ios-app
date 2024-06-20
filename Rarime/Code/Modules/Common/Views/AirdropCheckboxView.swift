import SwiftUI

struct AirdropCheckboxView: View {
    @EnvironmentObject private var configManager: ConfigManager
    @Binding var checked: Bool

    private var termsURL: String {
        configManager.general.termsOfUseURL.absoluteString
    }

    private var privacyURL: String {
        configManager.general.privacyPolicyURL.absoluteString
    }

    private var airdropTermsURL: String {
        configManager.general.airdropTerms.absoluteString
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            AppCheckbox(checked: $checked)
            (
                Text("By checking this box, you are agreeing to ") +
                    Text(.init("[\(String(localized: "RariMe General Terms & Conditions"))](\(termsURL))")).underline() +
                    Text(", ") +
                    Text(.init("[\(String(localized: "RariMe Privacy Notice"))](\(privacyURL))")).underline() +
                    Text(" and ") +
                    Text(.init("[\(String(localized: "Rarimo Airdrop Program Terms & Conditions"))](\(airdropTermsURL))")).underline()
            )
            .body4()
            .tint(.textSecondary)
            .foregroundStyle(.textSecondary)
            Spacer()
        }
    }
}

#Preview {
    AirdropCheckboxView(checked: .constant(true))
        .environmentObject(ConfigManager())
}
