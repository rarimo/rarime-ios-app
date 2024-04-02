//
//  ScanPassportMRZView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct ScanPassportMRZView: View {
    @ObservedObject var mrzScannerController: MRZScannerController
    let onNext: () -> Void
    let onClose: () -> Void

    init(
        mrzScannerController: MRZScannerController,
        onNext: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.mrzScannerController = mrzScannerController
        self.onNext = onNext
        self.onClose = onClose

        mrzScannerController.setOnScanned {
            onNext()
        }
    }

    var body: some View {
        ScanPassportLayoutView(
            step: 1,
            title: LocalizedStringResource("Scan your Passport"),
            text: LocalizedStringResource("Passport data is stored only on this device"),
            onClose: onClose
        ) {
            ZStack {
                MRZScannerView(mrzScannerController: mrzScannerController)
                LottieView(animation: Animations.passport, contentMode: .scaleToFill)
                    .frame(width: 350, height: 256)
                    .padding(.bottom, 2)
            }
            .frame(height: 300)
            Text("Move your PASSPORT page inside the border")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
                .frame(width: 250)
            Spacer()
        }
        .onAppear {
            mrzScannerController.startScanning()
        }
    }
}

#Preview {
    ScanPassportMRZView(
        mrzScannerController: MRZScannerController(),
        onNext: {},
        onClose: {}
    )
}
