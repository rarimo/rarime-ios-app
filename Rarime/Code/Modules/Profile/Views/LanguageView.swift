import SwiftUI

struct LanguageView: View {
    @EnvironmentObject private var settingsManager: SettingsManager
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Language"),
            onBack: onBack
        ) {
            CardContainer {
                HStack {
                    Text(settingsManager.language.title).subtitle4()
                    Spacer()
                    Image(Icons.check).iconMedium()
                }
                .foregroundColor(.textPrimary)
            }
        }
    }
}

#Preview {
    LanguageView(onBack: {})
        .environmentObject(SettingsManager())
}
