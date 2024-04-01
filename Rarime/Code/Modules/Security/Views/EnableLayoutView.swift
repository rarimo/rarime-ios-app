//
//  EnableLayoutView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 31.03.2024.
//

import SwiftUI

struct EnableLayoutView: View {
    let icon: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let enableAction: () -> Void
    let skipAction: () -> Void

    var body: some View {
        VStack {
            VStack {
                Image(icon)
                    .square(72)
                    .foregroundStyle(.primaryDarker)
            }
            .padding(40)
            .background(.primaryLighter)
            .clipShape(Circle())
            VStack(spacing: 12) {
                Text(title)
                    .h4()
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                Text(description)
                    .body3()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.vertical, 64)
            Spacer()
            VStack(spacing: 16) {
                HorizontalDivider()
                VStack(spacing: 8) {
                    Button(action: enableAction) {
                        Text("Enable")
                            .buttonLarge()
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(PrimaryButtonStyle())
                    Button(action: skipAction) {
                        Text("Maybe Later")
                            .buttonLarge()
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(TertiaryButtonStyle())
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 72)
        .padding(.bottom, 16)
        .background(.backgroundPure)
    }
}

#Preview {
    EnableLayoutView(
        icon: Icons.password,
        title: "Enable\nPasscode",
        description: "Enable Passcode Authentication",
        enableAction: {},
        skipAction: {}
    )
}
