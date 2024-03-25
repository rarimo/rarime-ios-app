//
//  ButtonStyle.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import Foundation
import SwiftUI

private func getButtonHeight(_ controlSize: ControlSize) -> CGFloat {
    switch controlSize {
    case .small: return 40
    default: return 48
    }
}

private let buttonCornerRadius: CGFloat = 1000
private let buttonPaddingHorizontal: CGFloat = 32

struct PrimaryContainedButtonStyle: ButtonStyle {
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: getButtonHeight(controlSize))
            .padding(.horizontal, buttonPaddingHorizontal)
            .background(configuration.isPressed ? .primaryDark : .primaryMain)
            .foregroundColor(.baseBlack)
            .cornerRadius(buttonCornerRadius)
    }
}

struct SecondaryContainedButtonStyle: ButtonStyle {
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: getButtonHeight(controlSize))
            .padding(.horizontal, buttonPaddingHorizontal)
            .background(configuration.isPressed ? .componentPressed : .componentPrimary)
            .foregroundColor(.textPrimary)
            .cornerRadius(buttonCornerRadius)
    }
}

#Preview {
    VStack(alignment: .leading) {
        Button(action: {}) {
            Text("Regular").buttonMedium()
        }
        .buttonStyle(PrimaryContainedButtonStyle())

        Button(action: {}) {
            Text("Small").buttonMedium()
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
