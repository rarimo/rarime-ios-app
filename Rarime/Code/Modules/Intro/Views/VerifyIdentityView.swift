//
//  VerifyPhraseView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import SwiftUI

struct VerifyIdentityView: View {
    let onBack: () -> Void
    let onNext: () -> Void

    @State var selectedWords: [String] = ["", "", ""]
    @State var isErrorSheetPresented = false

    func verifyWords() -> Bool {
        return selectedWords == ["explore", "apple", "features"]
    }

    var body: some View {
        IdentityStepLayoutView(
            step: 2,
            title: "Verify your recovery phrase",
            onBack: onBack,
            nextButton: { continueButton }
        ) {
            CardContainerView {
                VStack(spacing: 24) {
                    WordSelectorView(
                        wordNumber: 2,
                        selectedWord: $selectedWords[0],
                        wordOptions: ["domain", "explore", "club"]
                    )
                    WordSelectorView(
                        wordNumber: 5,
                        selectedWord: $selectedWords[1],
                        wordOptions: ["apple", "music", "features"]
                    )
                    WordSelectorView(
                        wordNumber: 10,
                        selectedWord: $selectedWords[2],
                        wordOptions: ["party", "engage", "features"]
                    )
                }
            }
            .dynamicSheet(isPresented: $isErrorSheetPresented) {
                IncorrectSelectionView(onTryAgain: {
                    isErrorSheetPresented = false
                })
            }
        }
    }

    var continueButton: some View {
        Button(action: {
            if verifyWords() {
                onNext()
            } else {
                isErrorSheetPresented = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }) {
            HStack(spacing: 8) {
                Text("Next").buttonLarge()
                Image(Icons.arrowRight).iconSmall()
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(selectedWords.contains(""))
        .controlSize(.large)
        .buttonStyle(PrimaryContainedButtonStyle())
    }
}

private struct WordSelectorView: View {
    let wordNumber: Int
    let selectedWord: Binding<String>
    let wordOptions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Word #\(wordNumber)").subtitle4()
            HStack(spacing: 12) {
                ForEach(wordOptions, id: \.self) { option in
                    WordOptionView(
                        word: option,
                        isSelected: selectedWord.wrappedValue == option
                    ) {
                        selectedWord.wrappedValue = option
                    }
                }
            }
        }
    }
}

private struct WordOptionView: View {
    let word: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(word).body3()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(isSelected ? .primaryMain : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? .clear : .componentPrimary, lineWidth: 1)
        )
        .foregroundColor(isSelected ? .baseBlack : .textPrimary)
    }
}

private struct IncorrectSelectionView: View {
    let onTryAgain: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Image(Icons.info)
                    .iconLarge()
                    .foregroundColor(.errorMain)
            }
            .padding(20)
            .background(.errorLighter)
            .clipShape(Circle())
            VStack(spacing: 12) {
                Text("Incorrect")
                    .h5()
                    .foregroundColor(.textPrimary)
                Text("Selections not matched. please try again")
                    .body2()
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 8)
            HorizontalDivider()
                .padding(.top, 16)
                .padding(.horizontal, -20)
            Button(action: onTryAgain) {
                Text("Try Again")
                    .buttonLarge()
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(PrimaryContainedButtonStyle())
        }
    }
}

#Preview {
    VerifyIdentityView(onBack: {}, onNext: {})
}
