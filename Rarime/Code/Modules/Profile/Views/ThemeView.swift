import SwiftUI

struct ThemeView: View {
    @EnvironmentObject private var settingsManager: SettingsManager
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Theme"),
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                    ThemeItem(
                        scheme: scheme,
                        isSelected: settingsManager.colorScheme == scheme
                    ) {
                        settingsManager.setColorScheme(scheme)
                        FeedbackGenerator.shared.impact(.light)
                    }
                }
            }
        }
    }
}

private struct ThemeItem: View {
    let scheme: AppColorScheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        AppRadioButton(isSelected: isSelected, onSelect: onSelect) {
            HStack(spacing: 16) {
                Image(scheme.image)
                    .resizable()
                    .frame(width: 40, height: 48)
                Text(scheme.title)
                    .buttonMedium()
                    .foregroundStyle(.textPrimary)
            }
        }
    }
}

private struct PreviewView: View {
    @StateObject private var settingsManager = SettingsManager()

    var body: some View {
        ThemeView(onBack: {})
            .preferredColorScheme(settingsManager.colorScheme.rawScheme)
            .environmentObject(settingsManager)
    }
}

#Preview {
    PreviewView()
}
