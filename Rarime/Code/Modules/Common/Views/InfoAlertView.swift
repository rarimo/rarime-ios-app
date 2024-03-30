//
//  InfoAlertView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import SwiftUI

struct InfoAlertView<Content: View>: View {
    var text: LocalizedStringResource
    @ViewBuilder var actionButton: () -> Content

    var body: some View {
        HStack(spacing: 8) {
            Image(Icons.info).iconMedium()
            Text(text).body3()
            Spacer()
            actionButton()
        }
        .padding(8)
        .foregroundColor(.warningDarker)
        .background(.warningLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    VStack(spacing: 16) {
        InfoAlertView(text: LocalizedStringResource("This is a warning message")) {}
        InfoAlertView(text: LocalizedStringResource("This is a warning message with an action button on the right")) {
            Button(action: {}) {
                Image(Icons.caretRight).iconMedium()
            }
        }
    }
    .padding(16)
}
