import SwiftUI

struct LanguageView: View {
    @EnvironmentObject private var settingsManager: SettingsManager
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Language"),
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    LanguageItem(
                        language: language,
                        isSelected: settingsManager.language == language
                    ) {
                        settingsManager.setLanguage(language)
                        FeedbackGenerator.shared.impact(.light)
                    }
                }
            }
        }
    }
}

private struct LanguageItem: View {
    let language: AppLanguage
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        AppRadioButton(isSelected: isSelected, onSelect: onSelect) {
            HStack(spacing: 16) {
                Text(language.flag)
                    .h6()
                    .foregroundStyle(.textPrimary)
                Text(language.title)
                    .buttonMedium()
                    .foregroundStyle(.textPrimary)
            }
        }
    }
}

#Preview {
    LanguageView(onBack: {})
        .environmentObject(SettingsManager())
}
