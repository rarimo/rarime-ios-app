//
//  ScanPassportLayoutView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

private let TOTAL_STEPS = 3

struct ScanPassportLayoutView<Content: View>: View {
    let step: Int
    let title: LocalizedStringResource
    let text: LocalizedStringResource
    let onClose: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Step \(step)/\(TOTAL_STEPS)")
                        .body3()
                        .foregroundStyle(.textSecondary)
                    Spacer()
                    Button(action: onClose) {
                        Image(Icons.close)
                            .iconMedium()
                            .foregroundStyle(.textPrimary)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .subtitle2()
                        .foregroundStyle(.textPrimary)
                    Text(text)
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview {
    ScanPassportLayoutView(
        step: 1,
        title: LocalizedStringResource("Scan your Passport"),
        text: LocalizedStringResource("Passport data is stored only on this device"),
        onClose: {}
    ) {
        Rectangle()
            .fill(.black)
            .frame(height: 300)
            .padding(.top, 20)
        Spacer()
    }
}
