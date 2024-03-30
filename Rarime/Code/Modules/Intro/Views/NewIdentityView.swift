//
//  CreateIdentityView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import SwiftUI

let wordlist = [
    "domain",
    "explore",
    "lion",
    "simple",
    "apple",
    "club",
    "similar",
    "music",
    "party",
    "engage",
    "car",
    "feature",
]

struct NewIdentityView: View {
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var isCopied = false

    var body: some View {
        IdentityStepLayoutView(
            step: 1,
            title: "New recovery phrase",
            onBack: onBack,
            nextButton: {
                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Continue").buttonLarge()
                        Image(Icons.arrowRight).iconSmall()
                    }
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(PrimaryContainedButtonStyle())
            }
        ) {
            CardContainerView {
                VStack(spacing: 20) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible()),
                        ],
                        spacing: 20
                    ) {
                        ForEach(Array(wordlist.enumerated()), id: \.element) { index, word in
                            HStack {
                                Text(String("\(index + 1).")).subtitle5().foregroundColor(.textPrimary)
                                Text(word).body3().foregroundColor(.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.componentPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Button(action: {
                        if isCopied { return }

                        UIPasteboard.general.string = wordlist.joined(separator: " ")
                        isCopied = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isCopied = false
                        }
                    }) {
                        HStack {
                            Image(isCopied ? Icons.check : Icons.copySimple).iconMedium()
                            Text(isCopied ? "Copied" : "Copy to clipboard").buttonMedium()
                        }
                        .foregroundStyle(.textPrimary)
                    }
                    HorizontalDivider()
                    InfoAlertView(text: "Don’t share your recovery phrase with anyone") {}
                }
            }
        }
    }
}

#Preview {
    NewIdentityView(onBack: {}, onNext: {})
}
