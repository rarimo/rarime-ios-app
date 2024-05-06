import SwiftUI

struct AppIconView: View {
    @EnvironmentObject private var appIconManager: AppIconManager
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "App Icon"),
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    AppIconItem(
                        icon: icon,
                        isSelected: appIconManager.appIcon == icon
                    ) {
                        appIconManager.setAppIcon(icon)
                        FeedbackGenerator.shared.impact(.light)
                    }
                }
            }
        }
    }
}

private struct AppIconItem: View {
    let icon: AppIcon
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        AppRadioButton(isSelected: isSelected, onSelect: onSelect) {
            HStack(spacing: 16) {
                Image(uiImage: UIImage(named: icon.rawValue) ?? UIImage())
                    .square(40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.componentPrimary, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(icon.title)
                    .buttonMedium()
                    .foregroundStyle(.textPrimary)
            }
        }
    }
}

#Preview {
    AppIconView(onBack: {})
        .environmentObject(AppIconManager())
}
