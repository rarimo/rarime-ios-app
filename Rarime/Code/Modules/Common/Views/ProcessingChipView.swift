//
//  ProcessingChipView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 02.04.2024.
//

import SwiftUI

struct ProcessingChipView: View {
    let status: ProcessingStatus

    var body: some View {
        HStack {
            if let icon = status.icon {
                Image(icon).iconSmall()
            }
            Text(status.text).overline3()
        }
        .frame(height: 24)
        .padding(.horizontal, 8)
        .background(status.backgroundColor)
        .clipShape(Capsule())
        .foregroundStyle(status.foregroundColor)
        .animation(.easeInOut, value: status)
    }
}
