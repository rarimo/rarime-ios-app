import SwiftUI

struct PollResult: Codable {
    let questionIndex: Int
    let answerIndex: Int?
}

struct ActivePollOptionsView: View {
    let poll: Poll
    
    let onSubmit: ([PollResult]) -> Void

    @State private var currentOptionIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var pollResults: [PollResult] = []

    var currentQuestion: Question {
        poll.questions[currentOptionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                if poll.questions.count == 1 {
                    Text("Select answer")
                } else {
                    Text("\(currentOptionIndex + 1). \(currentQuestion.title)")
                        .multilineTextAlignment(.leading)
                }
            }
            .subtitle5()
            .foregroundStyle(.textPrimary)
            ScrollView(.vertical) {
                VStack(spacing: 8) {
                    ForEach(Array(zip(
                        currentQuestion.variants.indices,
                        currentQuestion.variants
                    )), id: \.0) { index, option in
                        Button(action: {
                            withAnimation {
                                selectedOption = index
                            }
                        }) {
                            HStack(alignment: .center, spacing: 16) {
                                if selectedOption == index {
                                    Image(Icons.checkLine)
                                        .iconMedium()
                                        .foregroundStyle(.textPrimary)
                                } else {
                                    Text("\(index + 1)")
                                        .overline2()
                                        .foregroundStyle(.textSecondary)
                                }
                                VerticalDivider()
                                Text(option)
                                    .buttonMedium()
                                    .foregroundStyle(.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal, 16)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedOption == index ? .clear : .bgComponentPrimary)
                                .overlay {
                                    if selectedOption == index {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.primaryMain, lineWidth: 1)
                                    }
                                }
                        }
                    }
                }
            }
            AppButton(
                text: currentOptionIndex == poll.questions.count - 1 ? "Submit" : "Next",
                action: {
                    pollResults.append(PollResult(questionIndex: currentOptionIndex, answerIndex: selectedOption))
                    if currentOptionIndex < poll.questions.count - 1 {
                        currentOptionIndex += 1
                        selectedOption = nil
                    } else {
                        onSubmit(pollResults)
                    }
                }
            )
            .controlSize(.large)
            .disabled(selectedOption == nil)
        }
    }
}

#Preview {
    ActivePollOptionsView(poll: ACTIVE_POLLS[0], onSubmit: { _ in })
        .padding(.horizontal, 24)
}
