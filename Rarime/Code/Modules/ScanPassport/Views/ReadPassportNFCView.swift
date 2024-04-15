//
//  ReadPassportNFCView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct ReadPassportNFCView: View {
    @EnvironmentObject var mrzViewModel: MRZViewModel

    let onNext: (_ passport: Passport) -> Void
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScanPassportLayoutView(
            step: 2,
            title: "NFC Reader",
            text: "Reading Passport data",
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
                AppButton(text: "Start") {
                    NFCScanner.scanPassport(
                        mrzViewModel.mrzKey,
                        onCompletion: { result in
                            switch result {
                            case .success(let passport):
                                self.onNext(passport)
                            case .failure:
                                self.onBack()
                            }
                        }
                    )
                }
                .controlSize(.large)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ReadPassportNFCView(
        onNext: { _ in },
        onBack: {},
        onClose: {}
    )
    .environmentObject(MRZViewModel())
}
