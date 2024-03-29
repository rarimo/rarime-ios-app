//
//  HorizontalDivider.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//
import SwiftUI

struct HorizontalDivider: View {
    let color: Color
    let height: CGFloat

    init(color: Color = .componentPrimary, height: CGFloat = 1) {
        self.color = color
        self.height = height
    }

    var body: some View {
        color.frame(height: height)
    }
}
