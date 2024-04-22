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
                    ThemeRow(
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

private struct ThemeRow: View {
    let scheme: AppColorScheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(scheme.image)
                    .resizable()
                    .frame(width: 40, height: 48)
                Text(scheme.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Spacer()
                Circle()
                    .stroke(.componentHovered, lineWidth: 2)
                    .frame(width: 16)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? .primaryDark : .clear, lineWidth: 5)
                            .frame(width: 13)
                    )
            }
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.componentHovered, lineWidth: 1)
            )
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
