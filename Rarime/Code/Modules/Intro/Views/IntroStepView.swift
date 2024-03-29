//
//  IntroStepView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import SwiftUI

struct IntroStepView: View {
    let step: IntroStep

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 70) {
                Image(step.image).square(390)
                VStack(alignment: .leading, spacing: 16) {
                    Text(step.title).h4().foregroundStyle(.textPrimary)
                    Text(step.text).body2()
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, 24)
            }
            Spacer()
        }
    }
}

#Preview {
    IntroStepView(step: .privacy)
}
