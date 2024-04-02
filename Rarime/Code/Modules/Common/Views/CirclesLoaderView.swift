//
//  CirclesLoaderView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 02.04.2024.
//

import SwiftUI

struct CirclesLoaderView: View {
    let size: CGFloat = 4

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0 ..< 3) { index in
                Circle()
                    .fill(.warningDark)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .offset(y: isAnimating ? size : -size)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(0.15 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}
