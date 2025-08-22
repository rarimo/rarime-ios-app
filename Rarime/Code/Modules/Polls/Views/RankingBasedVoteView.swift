import SwiftUI

// MARK: - Data Models

struct VariantItem: Identifiable, Equatable {
    let id: UUID = .init()
    let answerIndex: Int
    let text: String
}

// MARK: - Main View

private enum RankingBaseVoteState {
    case rankingVote
    case previewResponse
}

struct RankingBasedVoteView: View {
    let selectedPoll: Poll
    let onBackClick: () -> Void
    let onClick: ([PollResult]) -> Void

    @State private var currentState: RankingBaseVoteState = .rankingVote
    @State private var currentRanking: [PollResult] = []
    @State private var items: [VariantItem] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Ranking Based Voting")
                    .font(.headline)
                    .padding(.horizontal, 20)
                Spacer()
                Button(action: onBackClick) {
                    Image(systemName: "xmark")
                        .padding()
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 15)

            switch currentState {
            case .rankingVote:
                RankingView(
                    question: selectedPoll.questions[0],
                    items: $items,
                    initialRanking: currentRanking,
                    onSubmit: { resultList in
                        currentRanking = resultList
                        currentState = .previewResponse
                    }
                )
            case .previewResponse:
                PreviewRankingResponceView(
                    question: selectedPoll.questions[0],
                    ranking: currentRanking,
                    onEdit: { currentState = .rankingVote },
                    onSubmit: { onClick(currentRanking) }
                )
            }
        }
    }
}

// MARK: - Ranking View

struct RankingView: View {
    let question: Question
    @Binding var items: [VariantItem]
    let initialRanking: [PollResult]
    let onSubmit: ([PollResult]) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(question.title)
                .font(.title)

            Text("Rank these options by priority. Drag and drop to sort them from your most preferred to least preferred choice.")
                .font(.subheadline)

            List {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Image("Draggable")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 12)

                        VerticalDivider()
                            .padding(.horizontal, 12)

                        Text(item.text)
                            .font(.body)
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(Color.bgComponentBasePrimary)
                    .cornerRadius(20)
                    .shadow(color: .clear, radius: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.bgContainer)
                    .contentShape(RoundedRectangle(cornerRadius: 20))
                }
                .onMove { indices, newOffset in
                    items.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .scrollDisabled(true)
            .listStyle(.plain)
            .padding(.top, 20)

            AppButton(
                variant: .primary,
                text: "Submit Ranking",
                action: {
                    let rankingOrder = items.enumerated().map { index, item in
                        PollResult(
                            questionIndex: index,
                            answerIndex: item.answerIndex
                        )
                    }
                    onSubmit(rankingOrder)
                }
            )
            .controlSize(.large)
            .padding(.top, 24)
        }
        .padding(.horizontal, 20)
        .onAppear {
            guard items.isEmpty else { return }

            if !initialRanking.isEmpty {
                items = initialRanking.compactMap { result in
                    if let index = result.answerIndex, index < question.variants.count {
                        return VariantItem(answerIndex: index, text: question.variants[index])
                    }
                    return nil
                }
            } else {
                items = question.variants.enumerated().map { index, text in
                    VariantItem(answerIndex: index, text: text)
                }
            }
        }
    }
}

// MARK: - Preview View

struct PreviewRankingResponceView: View {
    let question: Question
    let ranking: [PollResult]
    let onEdit: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.title)
                .font(.title)

            ForEach(ranking.indices, id: \.self) { index in
                let result = ranking[index]
                let answerText = result.answerIndex.map { question.variants[$0] } ?? "—"

                HStack {
                    Text("\(index + 1).")
                        .font(.headline)
                        .frame(width: 30)
                    Text(answerText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Spacer()

            HStack(spacing: 12) {
                AppButton(
                    variant: .secondary,
                    text: "Edit",
                    action: { onEdit() }
                )
                .controlSize(.large)

                AppButton(
                    variant: .primary,
                    text: "Submit",
                    action: { onSubmit() }
                )
                .controlSize(.large)
            }
        }
        .padding(24)
    }
}
