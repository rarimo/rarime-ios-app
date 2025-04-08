import SwiftUI

enum ButtonVariant {
    case primary, secondary, tertiary, quartenary
}

private struct ButtonColors {
    let background: Color
    let backgroundPressed: Color
    let backgroundDisabled: Color

    let foreground: Color
    let foregroundDisabled: Color
}

private let primaryColors = ButtonColors(
    background: .textPrimary,
    backgroundPressed: .textSecondary,
    backgroundDisabled: .bgComponentDisabled,
    foreground: .invertedLight,
    foregroundDisabled: .textDisabled
)

private let secondaryColors = ButtonColors(
    background: .bgComponentPrimary,
    backgroundPressed: .bgComponentPrimary,
    backgroundDisabled: .bgComponentPrimary,
    foreground: .textPrimary,
    foregroundDisabled: .textDisabled
)

private let tertiaryColors = ButtonColors(
    background: .bgComponentBasePrimary,
    backgroundPressed: .bgComponentBasePressed,
    backgroundDisabled: .bgComponentBaseDisabled,
    foreground: .baseBlack,
    foregroundDisabled: .baseBlack.opacity(0.5)
)

private let quaternaryColors = ButtonColors(
    background: .clear,
    backgroundPressed: .bgComponentPressed,
    backgroundDisabled: .bgComponentDisabled,
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
        case .quartenary: quaternaryColors
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
        case .large: 56
        default: 48
        }
    }

    private var paddingHorizontal: CGFloat {
        switch controlSize {
        case .small: 16
        case .large: 14
        default: 24
        }
    }
    
    private var cornerRadius: CGFloat {
        switch controlSize {
        case .small: 12
        case .large: 20
        default: 16
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
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
        AppButton(
            text: LocalizedStringResource("Primary", table: "preview"),
            action: {}
        )
        .controlSize(.large)
        AppButton(
            text: LocalizedStringResource("Primary Medium", table: "preview"),
            width: nil,
            action: {}
        )
        .disabled(true)
        AppButton(
            text: LocalizedStringResource("Primary Small", table: "preview"),
            width: nil,
            action: {}
        )
        .controlSize(.small)
        AppButton(
            variant: .secondary,
            text: LocalizedStringResource("Secondary", table: "preview"),
            action: {}
        ).controlSize(.large)
        AppButton(
            variant: .secondary,
            text: LocalizedStringResource("Secondary", table: "preview"),
            action: {}
        )
        .disabled(true)
        AppButton(
            variant: .secondary,
            text: LocalizedStringResource("Secondary", table: "preview"),
            action: {}
        ).controlSize(.small)
        AppButton(
            variant: .tertiary,
            text: LocalizedStringResource("Tertiary", table: "preview"),
            action: {}
        ).controlSize(.large)
        AppButton(
            variant: .tertiary,
            text: LocalizedStringResource("Tertiary", table: "preview"),
            action: {}
        )
        .disabled(true)
        AppButton(
            variant: .tertiary,
            text: LocalizedStringResource("Tertiary", table: "preview"),
            action: {}
        ).controlSize(.small)
        AppButton(
            variant: .quartenary,
            text: LocalizedStringResource("Quartenary", table: "preview"),
            action: {}
        ).controlSize(.large)
        AppButton(
            variant: .quartenary,
            text: LocalizedStringResource("Quartenary", table: "preview"),
            action: {}
        )
        .disabled(true)
        AppButton(
            variant: .quartenary,
            text: LocalizedStringResource("Quartenary", table: "preview"),
            action: {}
        ).controlSize(.small)
    }
    .padding(.horizontal, 24)
}
