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

    var body: some View {
        switch state {
        case .scanMRZ:
            ScanPassportMRZView(
                onNext: { withAnimation { state = .readNFC } },
                onClose: onClose
            ).transition(.backslide)
        case .readNFC:
            Text("Read NFC").transition(.backslide)
        case .selectData:
            Text("Select Data").transition(.backslide)
        case .generateProof:
            Text("Generate Proof").transition(.backslide)
        }
    }
}

#Preview {
    ScanPassportView(onClose: {})
}
