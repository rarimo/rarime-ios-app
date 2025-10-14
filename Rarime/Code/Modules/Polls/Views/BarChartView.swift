import SwiftUI

struct BarChartPollView: View {
    let result: QuestionResult
    let totalVotes: Int
    var isRankingBased: Bool = false

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
                        let text = isRankingBased ? "points" : "vote(s)"
                        Text("\(option.votes.formatted(.number)) \(text)")
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
    BarChartPollView(
        result: QuestionResult(
            question: "Do you worry about online privacy?",
            options: [
                QuestionResultOption(
                    answer: "Yes, very",
                    votes: 200
                ),
                QuestionResultOption(
                    answer: "Somewhat",
                    votes: 200
                ),
                QuestionResultOption(
                    answer: "Not at all",
                    votes: 200
                )
            ]
        ),
        totalVotes: 1000
    )
}
