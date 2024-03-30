//
//  PhraseStepLayoutView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 30.03.2024.
//

import SwiftUI

let totalSteps = 2

struct IdentityStepLayoutView<Content: View, NextButton: View>: View {
    let step: Int
    let title: LocalizedStringResource
    let onBack: () -> Void

    @ViewBuilder var nextButton: () -> NextButton
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(Icons.caretLeft).iconMedium().foregroundColor(.textPrimary)
                    }
                    Spacer()
                    Text("Step \(step)/\(totalSteps)").body3().foregroundColor(.textSecondary)
                }
                VStack(alignment: .leading, spacing: 32) {
                    Text(title).subtitle2().foregroundColor(.textPrimary)
                    content()
                }
                .padding(.vertical, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            Spacer()
            HStack {
                nextButton()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.backgroundPure)
        }
        .background(.backgroundPrimary)
    }
}

#Preview {
    IdentityStepLayoutView(
        step: 1,
        title: "New recovery phrase",
        onBack: {},
        nextButton: { Button("Next") {} }
    ) {}
}
