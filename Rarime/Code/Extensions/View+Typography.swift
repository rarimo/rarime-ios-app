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
    func applyFont(fontFamily: String? = nil, fontSize: CGFloat, lineHeight: CGFloat, fontWeight: UIFont.Weight = .regular) -> some View {
        let fontName = fontFamily ?? getFontFamily(weight: fontWeight)
        let font = UIFont(
            name: fontName,
            size: fontSize
        ) ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        
        let lineSpacing = lineHeight - font.lineHeight
        
        return self
            .font(Font(font))
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
    
    // additional
    func additional1() -> some View {
        self
            .applyFont(fontFamily: Fonts.playfairBold, fontSize: 48, lineHeight: 40, fontWeight: .bold)
            .kerning(-1.92)
    }
    
    func additional2() -> some View {
        self.applyFont(fontFamily: Fonts.playfairBold, fontSize: 40, lineHeight: 36, fontWeight: .bold)
    }
    
    func additional3() -> some View {
        self
            .applyFont(fontFamily: Fonts.playfairBold, fontSize: 24, lineHeight: 24, fontWeight: .bold)
            .kerning(-0.96)
    }
    
    // headline
    func h1() -> some View {
        self.applyFont(fontSize: 40, lineHeight: 48, fontWeight: .bold)
    }
    
    func h2() -> some View {
        self.applyFont(fontSize: 32, lineHeight: 36, fontWeight: .bold)
    }
    
    func h3() -> some View {
        self.applyFont(fontSize: 24, lineHeight: 28, fontWeight: .bold)
    }
    
    func h4() -> some View {
        self.applyFont(fontSize: 20, lineHeight: 24, fontWeight: .bold)
    }
    
    func h5() -> some View {
        self.applyFont(fontSize: 16, lineHeight: 20, fontWeight: .bold)
    }
    
    func h6() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 18, fontWeight: .bold)
    }
    
    // subtitle
    func subtitle1() -> some View {
        self.applyFont(fontSize: 48, lineHeight: 52, fontWeight: .medium)
    }
    
    func subtitle2() -> some View {
        self.applyFont(fontSize: 40, lineHeight: 44, fontWeight: .medium)
    }
    
    func subtitle3() -> some View {
        self.applyFont(fontSize: 32, lineHeight: 36, fontWeight: .medium)
    }
    
    func subtitle4() -> some View {
        self.applyFont(fontSize: 20, lineHeight: 24, fontWeight: .medium)
    }
    
    func subtitle5() -> some View {
        self.applyFont(fontSize: 16, lineHeight: 22, fontWeight: .medium)
    }
    
    func subtitle6() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 20, fontWeight: .medium)
    }
    
    func subtitle7() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 18, fontWeight: .medium)
    }
    
    // body
    func body1() -> some View {
        self.applyFont(fontSize: 24, lineHeight: 28)
    }
    
    func body2() -> some View {
        self.applyFont(fontSize: 20, lineHeight: 28)
    }
    
    func body3() -> some View {
        self.applyFont(fontSize: 16, lineHeight: 22)
    }
    
    func body4() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 20)
    }
    
    func body5() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 18)
    }
    
    // button
    func buttonLarge() -> some View {
        self.applyFont(fontSize: 16, lineHeight: 20, fontWeight: .semibold)
    }
    
    func buttonMedium() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 18, fontWeight: .semibold)
    }
    
    func buttonSmall() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 14, fontWeight: .semibold)
    }
    
    // caption
    func caption1() -> some View {
        self.applyFont(fontSize: 14, lineHeight: 16, fontWeight: .medium)
    }
    
    func caption2() -> some View {
        self.applyFont(fontSize: 12, lineHeight: 14, fontWeight: .medium)
    }
    
    func caption3() -> some View {
        self.applyFont(fontSize: 10, lineHeight: 12, fontWeight: .medium)
    }
    
    // overline
    func overline1() -> some View {
        self
            .applyFont(fontSize: 14, lineHeight: 18, fontWeight: .semibold)
            .kerning(0.56)
            .textCase(.uppercase)
    }
    
    func overline2() -> some View {
        self
            .applyFont(fontSize: 12, lineHeight: 16, fontWeight: .semibold)
            .kerning(0.48)
            .textCase(.uppercase)
    }
    
    func overline3() -> some View {
        self
            .applyFont(fontSize: 10, lineHeight: 12, fontWeight: .semibold)
            .kerning(0.4)
            .textCase(.uppercase)
    }
}
