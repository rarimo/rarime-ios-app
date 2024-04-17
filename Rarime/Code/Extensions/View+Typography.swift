import SwiftUI

private func getFontFamily(weight: UIFont.Weight) -> String {
    switch weight {
        case .bold:
            return Fonts.interBold
        case .semibold:
            return Fonts.interSemibold
        case .medium:
            return Fonts.interMedium
        default:
            return Fonts.interRegular
    }
}

extension View {
    func applyFont(fontSize: CGFloat, lineHeight: CGFloat, fontWeight: UIFont.Weight = .regular) -> some View {
        let font = UIFont(
            name: getFontFamily(weight: fontWeight),
            size: fontSize
        ) ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        
        let lineSpacing = lineHeight - font.lineHeight
        
        return self
            .font(Font(font))
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
    
    // headline
    func h1() -> some View {
        self.applyFont(fontSize: 96, lineHeight: 96, fontWeight: .bold)
    }
    
    func h2() -> some View {
        self.applyFont(fontSize: 60, lineHeight: 70, fontWeight: .bold)
    }
    
    func h3() -> some View {
        self.applyFont(fontSize: 48, lineHeight: 56, fontWeight: .bold)
    }
    
    func h4() -> some View {
        self.applyFont(fontSize: 32, lineHeight: 40, fontWeight: .bold)
    }
    
    func h5() -> some View {
        self.applyFont(fontSize: 24, lineHeight: 30, fontWeight: .bold)
    }
    
    func h6() -> some View {
        self.applyFont(fontSize: 20, lineHeight: 24, fontWeight: .bold)
    }
    
    // subtitle
    func subtitle1() -> some View {
        self.applyFont(fontSize: 24, lineHeight: 30, fontWeight: .semibold)
    }
    
    func subtitle2() -> some View {
        self.applyFont(fontSize: 20, lineHeight: 24, fontWeight: .semibold)
    }
    
    func subtitle3() -> some View {
        self.applyFont(fontSize: 16, lineHeight: 20, fontWeight: .semibold)
    }
    
    func subtitle4() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 18, fontWeight: .semibold)
    }
    
    func subtitle5() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 16, fontWeight: .semibold)
    }
    
    // body
    func body1() -> some View {
        self
            .applyFont(fontSize: 20, lineHeight: 24)
            .kerning(0.4)
    }
    
    func body2() -> some View {
        self
            .applyFont(fontSize: 16, lineHeight: 20)
            .kerning(0.32)
    }
    
    func body3() -> some View {
        self
            .applyFont(fontSize: 14, lineHeight: 20)
            .kerning(0.28)
    }
    
    func body4() -> some View {
        self
            .applyFont(fontSize: 12, lineHeight: 16)
            .kerning(0.24)
    }
    
    // button
    func buttonLarge() -> some View {
        self.applyFont(fontSize: 16, lineHeight: 20, fontWeight: .medium)
    }
    
    func buttonMedium() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 18, fontWeight: .medium)
    }
    
    func buttonSmall() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 14, fontWeight: .medium)
    }
    
    // caption
    func caption1() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 18, fontWeight: .medium)
    }
    
    func caption2() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 16, fontWeight: .medium)
    }
    
    func caption3() -> some View {
        self.applyFont(fontSize: 10, lineHeight: 12, fontWeight: .medium)
    }
    
    // overline
    func overline1() -> some View {
        self
            .applyFont(fontSize: 14, lineHeight: 18, fontWeight: .bold)
            .kerning(0.56)
            .textCase(.uppercase)
    }
    
    func overline2() -> some View {
        self
            .applyFont(fontSize: 12, lineHeight: 16, fontWeight: .bold)
            .kerning(0.48)
            .textCase(.uppercase)
    }
    
    func overline3() -> some View {
        self
            .applyFont(fontSize: 10, lineHeight: 12, fontWeight: .bold)
            .kerning(0.4)
            .textCase(.uppercase)
    }
}
