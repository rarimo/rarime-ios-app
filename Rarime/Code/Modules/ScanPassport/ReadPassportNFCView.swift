//
//  ReadPassportNFCView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct ReadPassportNFCView: View {
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScanPassportLayoutView(
            step: 2,
            title: LocalizedStringResource("NFC Reader"),
            text: LocalizedStringResource("Reading Passport data"),
            onClose: onClose
        ) {
            Image("PassportNFC").square(280)
            Text("Place your passport cover to the back of your phone")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 48)
                .frame(width: 250)
            Spacer()
            VStack(spacing: 16) {
                HorizontalDivider()
                Button(action: onNext) {
                    Text("Start")
                        .buttonLarge()
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .controlSize(.large)
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ReadPassportNFCView(onNext: {}, onClose: {})
}