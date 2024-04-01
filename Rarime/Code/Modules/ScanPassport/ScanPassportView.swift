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
            ReadPassportNFCView(
                onNext: { withAnimation { state = .selectData } },
                onClose: onClose
            ).transition(.backslide)
        case .selectData:
            ScanPassportLayoutView(
                step: 3,
                title: "Select Data",
                text: "Selected data can be used as anonymised proofs",
                onClose: onClose
            ) {
                Rectangle()
                    .fill(.green)
                    .frame(height: 500)
                    .onTapGesture { withAnimation { state = .generateProof } }
                Spacer()
            }
            .transition(.backslide)
        case .generateProof:
            VStack {
                Text("Generate Proof")
                Button(action: onClose) {
                    Text("Close").buttonLarge()
                }
                .controlSize(.large)
                .buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.backslide)
        }
    }
}

#Preview {
    ScanPassportView(onClose: {})
}
