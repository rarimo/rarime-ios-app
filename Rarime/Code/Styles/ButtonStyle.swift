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
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: buttonHeight(controlSize))
            .padding(.horizontal, buttonPaddingHorizontal(controlSize))
            .background(isEnabled ? configuration.isPressed ? .primaryDark : .primaryMain : .componentDisabled)
            .foregroundColor(isEnabled ? .baseBlack : .textDisabled)
            .cornerRadius(buttonCornerRadius)
    }
}

struct SecondaryContainedButtonStyle: ButtonStyle {
    @Environment(\.controlSize) var controlSize
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: buttonHeight(controlSize))
            .padding(.horizontal, buttonPaddingHorizontal(controlSize))
            .background(isEnabled ? configuration.isPressed ? .componentPressed : .componentPrimary : .componentDisabled)
            .foregroundColor(isEnabled ? .textPrimary : .textDisabled)
            .cornerRadius(buttonCornerRadius)
    }
}

#Preview {
    VStack(alignment: .leading) {
        Button(action: {}) {
            Text(String("Large")).buttonLarge()
        }
        .buttonStyle(PrimaryContainedButtonStyle())
        .controlSize(.large)

        Button(action: {}) {
            Text(String("Regular")).buttonMedium()
        }
        .buttonStyle(PrimaryContainedButtonStyle())

        Button(action: {}) {
            Text(String("Small")).buttonSmall()
        }
        .buttonStyle(PrimaryContainedButtonStyle())
        .controlSize(.small)

        Button(action: {}) {
            HStack {
                Text(String("Full width with icon")).buttonMedium()
                Image(Icons.arrowRight).iconMedium()
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryContainedButtonStyle())

        Button(action: {}) {
            Text(String("Secondary")).buttonMedium().frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryContainedButtonStyle())
    }
    .padding()
}
