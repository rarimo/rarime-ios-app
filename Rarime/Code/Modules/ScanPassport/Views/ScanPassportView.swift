//
//  ScanPassportView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

private enum ScanPassportState {
    case scanMRZ, readNFC, selectData, generateProof
}

struct ScanPassportView: View {
    let onClose: () -> Void

    @State private var state: ScanPassportState = .scanMRZ
    @StateObject private var mrzScannerController = MRZScannerController()

    var body: some View {
        switch state {
        case .scanMRZ:
            ScanPassportMRZView(
                mrzScannerController: mrzScannerController,
                onNext: { withAnimation { state = .readNFC } },
                onClose: onClose
            ).transition(.backslide)
        case .readNFC:
            ReadPassportNFCView(
                onNext: { withAnimation { state = .selectData } },
                onClose: onClose
            ).transition(.backslide)
        case .selectData:
            SelectPassportDataView(
                onNext: { withAnimation { state = .generateProof } },
                onClose: onClose
            ).transition(.backslide)
        case .generateProof:
            PassportProofView(onFinish: onClose).transition(.backslide)
        }
    }
}

#Preview {
    ScanPassportView(onClose: {})
}
