import SwiftUI

enum ButtonVariant {
    case primary, secondary, tertiary
}

private struct ButtonColors {
    let background: Color
    let backgroundPressed: Color
    let backgroundDisabled: Color

    let foreground: Color
    let foregroundDisabled: Color
}

private let primaryColors = ButtonColors(
    background: .primaryMain,
    backgroundPressed: .primaryDark,
    backgroundDisabled: .componentDisabled,
    foreground: .baseBlack,
    foregroundDisabled: .textDisabled
)

private let secondaryColors = ButtonColors(
    background: .componentPrimary,
    backgroundPressed: .componentPressed,
    backgroundDisabled: .componentDisabled,
    foreground: .textPrimary,
    foregroundDisabled: .textDisabled
)

private let tertiaryColors = ButtonColors(
    background: .clear,
    backgroundPressed: .componentPressed,
    backgroundDisabled: .componentDisabled,
    foreground: .textPrimary,
    foregroundDisabled: .textDisabled
)

struct AppButtonStyle: ButtonStyle {
    var variant: ButtonVariant

    @Environment(\.isEnabled) var isEnabled

    private var colors: ButtonColors {
        switch variant {
        case .secondary: secondaryColors
        case .tertiary: tertiaryColors
        default: primaryColors
        }
    }

    private func getBgColor(_ isPressed: Bool) -> Color {
        if isEnabled {
            isPressed ? colors.backgroundPressed : colors.background
        } else {
            colors.backgroundDisabled
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(getBgColor(configuration.isPressed))
            .foregroundColor(isEnabled ? colors.foreground : colors.foregroundDisabled)
    }
}

struct AppButton: View {
    var variant: ButtonVariant = .primary

    var text: LocalizedStringResource
    var leftIcon: String?
    var rightIcon: String?

    var width: CGFloat? = .infinity
    var action: () -> Void

    @Environment(\.controlSize) var controlSize

    private var height: CGFloat {
        switch controlSize {
        case .small: 32
        case .large: 48
        default: 40
        }
    }

    private var paddingHorizontal: CGFloat {
        switch controlSize {
        case .small: 16
        case .large: 32
        default: 24
        }
    }

    private var iconSize: CGFloat {
        controlSize == .small ? 16 : 20
    }

    var body: some View {
        Button(action: action) {
            label
                .frame(height: height)
                .frame(maxWidth: width)
                .padding(.horizontal, paddingHorizontal)
        }
        .buttonStyle(AppButtonStyle(variant: variant))
        .clipShape(RoundedRectangle(cornerRadius: 1000))
    }

    var label: some View {
        HStack(spacing: 8) {
            if let leftIcon {
                Image(leftIcon).square(iconSize)
            }
            switch controlSize {
            case .small: Text(text).buttonSmall()
            case .large: Text(text).buttonLarge()
            default: Text(text).buttonMedium()
            }
            if let rightIcon {
                Image(rightIcon).square(iconSize)
            }
        }
    }
}

#Preview {
    VStack {
        AppButton(text: LocalizedStringResource("Primary", table: "preview"), action: {})
            .controlSize(.large)
        AppButton(
            text: LocalizedStringResource("Primary Medium", table: "preview"),
            leftIcon: Icons.arrowLeft,
            rightIcon: Icons.arrowRight,
            width: nil,
            action: {}
        )
        AppButton(text: LocalizedStringResource("Primary Small", table: "preview"), width: nil, action: {})
            .controlSize(.small)

        AppButton(
            variant: .secondary,
            text: LocalizedStringResource("Secondary", table: "preview"),
            leftIcon: Icons.arrowLeft,
            rightIcon: Icons.arrowRight,
            action: {}
        ).controlSize(.large)

        AppButton(
            variant: .tertiary,
            text: LocalizedStringResource("Tertiary", table: "preview"),
            leftIcon: Icons.arrowLeft,
            rightIcon: Icons.arrowRight,
            action: {}
        ).controlSize(.large)
    }
}
