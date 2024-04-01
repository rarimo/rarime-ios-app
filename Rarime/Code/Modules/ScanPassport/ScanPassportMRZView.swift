//
//  ScanPassportMRZView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct ScanPassportMRZView: View {
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScanPassportLayoutView(
            step: 1,
            title: LocalizedStringResource("Scan your Passport"),
            text: LocalizedStringResource("Passport data is stored only on this device"),
            onClose: onClose
        ) {
            Rectangle()
                .fill(.black)
                .frame(height: 300)
                .onTapGesture { onNext() }
            Text("Move your PASSPORT page inside the border")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
                .frame(width: 250)
            Spacer()
        }
    }
}

#Preview {
    ScanPassportMRZView(onNext: {}, onClose: {})
}
