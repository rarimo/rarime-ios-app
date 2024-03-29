//
//  ButtonStyle.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import Foundation
import SwiftUI

private func buttonHeight(_ controlSize: ControlSize) -> CGFloat {
    switch controlSize {
    case .small: return 32
    case .large: return 48
    default: return 40
    }
}

private func buttonPaddingHorizontal(_ controlSize: ControlSize) -> CGFloat {
    switch controlSize {
    case .small: return 16
    case .large: return 32
    default: return 24
    }
}

private let buttonCornerRadius: CGFloat = 1000

struct PrimaryContainedButtonStyle: ButtonStyle {
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: buttonHeight(controlSize))
            .padding(.horizontal, buttonPaddingHorizontal(controlSize))
            .background(configuration.isPressed ? .primaryDark : .primaryMain)
            .foregroundColor(.baseBlack)
            .cornerRadius(buttonCornerRadius)
    }
}

struct SecondaryContainedButtonStyle: ButtonStyle {
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: buttonHeight(controlSize))
            .padding(.horizontal, buttonPaddingHorizontal(controlSize))
            .background(configuration.isPressed ? .componentPressed : .componentPrimary)
            .foregroundColor(.textPrimary)
            .cornerRadius(buttonCornerRadius)
    }
}

#Preview {
    VStack(alignment: .leading) {
        Button(action: {}) {
            Text("Large").buttonLarge()
        }
        .buttonStyle(PrimaryContainedButtonStyle())
        .controlSize(.large)

        Button(action: {}) {
            Text("Regular").buttonMedium()
        }
        .buttonStyle(PrimaryContainedButtonStyle())

        Button(action: {}) {
            Text("Small").buttonSmall()
        }
        .buttonStyle(PrimaryContainedButtonStyle())
        .controlSize(.small)

        Button(action: {}) {
            HStack {
                Text("Full width with icon").buttonMedium()
                Image(Icons.arrowRight).iconMedium()
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryContainedButtonStyle())

        Button(action: {}) {
            Text("Secondary").buttonMedium().frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryContainedButtonStyle())
    }
    .padding()
}
