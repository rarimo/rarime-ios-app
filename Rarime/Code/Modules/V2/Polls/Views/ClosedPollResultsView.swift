import SwiftUI

struct ClosedPollResultsView: View {
    let poll: Poll
    
    var questionResults: [QuestionResult] {
        var results: [QuestionResult] = []
        for (question, result) in zip(poll.questions, poll.proposalResults) {
            results.append(
                QuestionResult(
                    question: question.title,
                    options: question.variants.enumerated().map { index, answer in
                        QuestionResultOption(
                            answer: answer,
                            votes: Int(result[index])
                        )
                    }
                )
            )
        }

        return results
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(questionResults.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        let totalVotes = questionResults[index].options.map(\.votes).reduce(0, +)
                        Text(questionResults[index].question)
                            .subtitle5()
                            .foregroundStyle(.textPrimary)
                        BarChartPollView(
                            result: questionResults[index],
                            totalVotes: totalVotes
                        )
                    }
                }
            }
        }
    }
}

private struct BarChartPollView: View {
    let result: QuestionResult
    let totalVotes: Int
    
    private var winnerOptionVotes: Int {
        result.options.map(\.votes).max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(result.options, id: \.self) { option in
                let isWinner = totalVotes > 0 && option.votes == winnerOptionVotes
                let votePercentage = totalVotes > 0 ? Double(option.votes) / Double(totalVotes) : 0
                HStack(alignment: .center, spacing: 0) {
                    Group {
                        if isWinner {
                            Text(option.answer)
                                .buttonLarge()
                        } else {
                            Text(option.answer)
                                .body4()
                        }
                    }
                    .foregroundStyle(.textPrimary)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(verbatim: "\(String(format: "%.2f", votePercentage * 100))%")
                            .subtitle6()
                            .foregroundStyle(.textPrimary)
                        Text(option.votes.formatted(.number))
                            .caption3()
                            .foregroundStyle(.textSecondary)
                    }
                }
                .padding(.all, 16)
                .frame(height: 48)
                .background(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.successLight)
                            .frame(
                                width: geometry.size.width * votePercentage,
                                height: geometry.size.height,
                                alignment: .leading
                            )
                    }
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.bgComponentPrimary, lineWidth: 1)
        }
    }
}

#Preview {
    ClosedPollResultsView(poll: FINISHED_POLLS[0])
        .padding(.horizontal, 20)
}
