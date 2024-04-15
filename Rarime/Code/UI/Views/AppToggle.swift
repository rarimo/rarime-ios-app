//
//  ToggleView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct AppToggle: View {
    @Binding var isOn: Bool
    var onChanged: ((Bool) -> Void)?

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(isOn ? .successMain : .componentPrimary)
                .frame(width: 40, height: 24)
                .overlay(
                    Circle()
                        .fill(.baseWhite)
                        .shadow(color: isOn ? .clear : .baseBlack.opacity(0.12), radius: 1, x: 1, y: 1)
                        .padding(2)
                        .offset(x: isOn ? 8 : -8))
                .animation(.easeInOut(duration: 0.2), value: isOn)
                .onTapGesture {
                    isOn.toggle()
                    onChanged?(isOn)
                    FeedbackGenerator.shared.impact(.light)
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let oldIsOn = isOn
                            isOn = value.translation.width >= 0
                            onChanged?(isOn)
                            if oldIsOn != isOn {
                                FeedbackGenerator.shared.impact(.light)
                            }
                        }
                )
        }
    }
}

private struct PreviewView: View {
    @State private var isOn = false

    var body: some View {
        VStack(alignment: .leading) {
            AppToggle(isOn: $isOn)
        }
    }
}

#Preview {
    PreviewView()
}
