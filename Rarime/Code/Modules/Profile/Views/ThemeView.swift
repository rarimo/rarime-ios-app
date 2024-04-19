import SwiftUI

enum AppColorScheme: CaseIterable {
    case light, dark, system

    var title: String {
        switch self {
        case .light: String(localized: "Light Mode")
        case .dark: String(localized: "Dark Mode")
        case .system: String(localized: "System")
        }
    }

    var image: String {
        switch self {
        case .light: Images.lightTheme
        case .dark: Images.darkTheme
        case .system: Images.systemTheme
        }
    }
}

struct ThemeView: View {
    let onBack: () -> Void

    // TODO: Move to ViewModel
    @State private var selectedColorScheme: AppColorScheme = .system

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Theme"),
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                    ThemeRow(
                        scheme: scheme,
                        isSelected: selectedColorScheme == scheme
                    ) {
                        selectedColorScheme = scheme
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

#Preview {
    ThemeView(onBack: {})
}
