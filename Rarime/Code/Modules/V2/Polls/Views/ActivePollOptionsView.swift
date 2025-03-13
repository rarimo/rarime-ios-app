import SwiftUI

struct ActivePollOptionsView: View {
    let poll: Poll
    
    let onSubmit: ([PollResult]) -> Void
    let onClose: () -> Void

    @State private var currentOptionIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var pollResults: [PollResult] = []

    private var currentQuestion: Question {
        poll.questions[currentOptionIndex]
    }
    
    private var isLastQuestion: Bool {
        currentOptionIndex == poll.questions.count - 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text("Question: \(currentOptionIndex + 1)/\(poll.questions.count)")
                    .subtitle6()
                    .foregroundStyle(.textSecondary)
                Spacer()
                AppIconButton(icon: Icons.closeFill, action: onClose)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            ZStack {
                if !isLastQuestion {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.bgSurface1.opacity(0.6))
                        .frame(height: 521)
                        .scaleEffect(0.9, anchor: .bottom)
                        .offset(y: 12)
                }
                VStack(alignment: .leading, spacing: 24) {
                    Text(currentQuestion.title)
                        .h4()
                        .foregroundStyle(.textPrimary)
                    HorizontalDivider()
                    Text("Select answer")
                        .subtitle5()
                        .foregroundStyle(.textPrimary)
                    ScrollView {
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
                                    .padding(.all, 16)
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
                }
                .padding(.all, 24)
                .frame(height: 520)
                .background(.bgSurface1)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .applyShadows([
                    ShadowConfig(color: Color.black.opacity(0.02), radius: 32, x: 0, y: 8),
                    ShadowConfig(color: Color.black.opacity(0.02), radius: 1,  x: 0, y: 0.55),
                    ShadowConfig(color: Color.black.opacity(0.02), radius: 32, x: 0, y: 0)
                ])
            }
            .padding(.horizontal, 8)
            Spacer()
            AppButton(
                text: isLastQuestion ? "Submit" : "Next",
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
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

#Preview {
    ActivePollOptionsView(poll: ACTIVE_POLLS[0], onSubmit: { _ in }, onClose: {})
        .environmentObject(PassportManager())
}
