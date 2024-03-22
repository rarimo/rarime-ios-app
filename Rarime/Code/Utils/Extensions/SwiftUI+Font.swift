//
//  SwiftUI+Font.swift
//  Rarime
//
//  Created by Ivan Lele on 21.03.2024.
//

import SwiftUI

extension Font {
    static func customFont(
        font: CustomFonts,
        style: CustomFontStyle,
        size: CGFloat
    ) -> Font {
        return Font.custom(
            font.rawValue + style.rawValue,
            size: size
        )
    }
}
