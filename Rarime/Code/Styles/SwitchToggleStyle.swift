//
//  SwitchToggleStyle.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct PrimarySwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? .successMain : .componentPrimary)
                .frame(width: 40, height: 24)
                .overlay(
                    Circle()
                        .fill(.baseWhite)
                        .shadow(color: configuration.isOn ? .clear : .baseBlack.opacity(0.12), radius: 1, x: 1, y: 1)
                        .padding(2)
                        .offset(x: configuration.isOn ? 8 : -8))
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                    FeedbackGenerator.shared.impact(.light)
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let oldIsOn = configuration.isOn
                            configuration.isOn = value.translation.width >= 0
                            if oldIsOn != configuration.isOn {
                                FeedbackGenerator.shared.impact(.light)
                            }
                        }
                )
            configuration.label
        }
    }
}

private struct PreviewView: View {
    @State private var isOn = false

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $isOn) {
                Text(String("Regular"))
                    .foregroundStyle(.textPrimary)
            }.toggleStyle(PrimarySwitchToggleStyle())
        }
    }
}

#Preview {
    PreviewView()
}
