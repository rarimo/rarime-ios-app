import SwiftUI

enum IconButtonVariant {
    case primary, secondary, tertiary
}

private struct IconButtonColors {
    let background: Color
    let backgroundPressed: Color
    let backgroundDisabled: Color

    let foreground: Color
    let foregroundDisabled: Color
}

private let primaryColors = IconButtonColors(
    background: .bgComponentPrimary,
    backgroundPressed: .bgComponentPressed,
    backgroundDisabled: .bgComponentDisabled,
    foreground: .textPrimary,
    foregroundDisabled: .textDisabled
)

private let secondaryColors = IconButtonColors(
    background: .bgComponentBasePrimary,
    backgroundPressed: .bgComponentBasePressed,
    backgroundDisabled: .bgComponentBaseDisabled,
    foreground: .baseBlack,
    foregroundDisabled: .baseBlack.opacity(0.28)
)

private let tertiaryColors = IconButtonColors(
    background: .clear,
    backgroundPressed: .bgComponentPressed,
    backgroundDisabled: .bgComponentDisabled,
    foreground: .textPrimary,
    foregroundDisabled: .textDisabled
)

struct AppIconButtonStyle: ButtonStyle {
    var variant: IconButtonVariant

    @Environment(\.isEnabled) var isEnabled

    private var colors: IconButtonColors {
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

struct AppIconButton: View {
    var variant: IconButtonVariant = .primary
    var icon: String
    var iconSize: CGFloat?
    var cornerRadius: CGFloat?
    var action: () -> Void

    @Environment(\.controlSize) var controlSize
    
    private var calculatedIconSize: CGFloat {
        iconSize ?? {
            switch controlSize {
            case .small:
                return 16
            case .large:
                return 24
            default:
                return 20
            }
        }()
    }

    private var buttonSize: CGFloat {
        switch controlSize {
        case .small: 32
        case .large: 56
        default: 40
        }
    }
    
    private var paddings: CGFloat {
        switch controlSize {
        case .small: 6
        case .large: 18
        default: 10
        }
    }
    
    private var calculatedCornerRadius: CGFloat {
        cornerRadius ?? 100
    }

    var body: some View {
        Button(action: action) {
            Image(icon)
                .square(calculatedIconSize)
                .padding(paddings)
        }
        .buttonStyle(AppIconButtonStyle(variant: variant))
        .clipShape(RoundedRectangle(cornerRadius: calculatedCornerRadius))
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 12){
            AppIconButton(icon: Icons.closeFill, action: {}).controlSize(.large)
            AppIconButton(icon: Icons.closeFill, action: {})
            AppIconButton(icon: Icons.closeFill, action: {}).controlSize(.small)
        }
        HStack(spacing: 12){
            AppIconButton(variant: .secondary, icon: Icons.closeFill, action: {}).controlSize(.large)
            AppIconButton(variant: .secondary, icon: Icons.closeFill, action: {})
            AppIconButton(variant: .secondary, icon: Icons.closeFill, action: {}).controlSize(.small)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        Gradients.gradientFirst
            .ignoresSafeArea(.all)
    )
}
