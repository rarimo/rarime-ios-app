//
//  Text.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 22.03.2024.
//

import Foundation
import SwiftUI

func getFontFamily(weight: UIFont.Weight) -> String {
    if weight == .bold {
        return Fonts.interBold
    } else if weight == .semibold {
        return Fonts.interSemibold
    } else if weight == .medium {
        return Fonts.interMedium
    } else {
        return Fonts.interRegular
    }
}

extension Text {
    func applyFont(fontSize: CGFloat, lineHeight: CGFloat, fontWeight: UIFont.Weight = .regular) -> some View {
        let font = UIFont(
            name: getFontFamily(weight: fontWeight),
            size: fontSize
        ) ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        
        return self
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
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

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading) {
                Text("Heading").overline1()
                    .foregroundColor(.textSecondary)
                Text("H1").h1()
                Text("H2").h2()
                Text("H3").h3()
                Text("H4").h4()
                Text("H5").h5()
                Text("H6").h6()
            }
            
            VStack(alignment: .leading) {
                Text("Subtitle").overline1()
                    .foregroundColor(.textSecondary)
                Text("Subtitle 1").subtitle1()
                Text("Subtitle 2").subtitle2()
                Text("Subtitle 3").subtitle3()
                Text("Subtitle 4").subtitle4()
                Text("Subtitle 5").subtitle5()
            }
            
            VStack(alignment: .leading) {
                Text("Body").overline1()
                    .foregroundColor(.textSecondary)
                Text("Body 1").body1()
                Text("Body 2").body2()
                Text("Body 3").body3()
                Text("Body 4").body4()
            }
            
            VStack(alignment: .leading) {
                Text("Button").overline1()
                    .foregroundColor(.textSecondary)
                Text("Button Large").buttonLarge()
                Text("Button Medium").buttonMedium()
                Text("Button Small").buttonSmall()
            }
            
            VStack(alignment: .leading) {
                Text("Caption").overline1()
                    .foregroundColor(.textSecondary)
                Text("Caption 1").caption1()
                Text("Caption 2").caption2()
                Text("Caption 3").caption3()
            }
            
            VStack(alignment: .leading) {
                Text("Overline").overline1()
                    .foregroundColor(.textSecondary)
                Text("Overline 1").overline1()
                Text("Overline 2").overline2()
                Text("Overline 3").overline3()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
