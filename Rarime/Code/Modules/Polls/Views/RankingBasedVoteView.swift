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
    let onClose: () -> Void
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
                Button(action: onClose) {
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
                PreviewRankingResponseView(
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
                .padding(.horizontal, 20)

            Text("Rank these options by priority. Drag and drop to sort them from your most preferred to least preferred choice.")
                .font(.subheadline)
                .padding(.horizontal, 20)

            List {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Image("Draggable")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.textPrimary)

                        VerticalDivider()

                        Text(item.text)
                            .font(.body)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.bgComponentBasePrimary)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                    .contentShape(RoundedRectangle(cornerRadius: 20))
                }
                .onMove { indices, newOffset in
                    items.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .padding(.horizontal, 20)
            .listStyle(.plain)
            .scrollDisabled(true)
            .environment(\.defaultMinListRowHeight, 0)

            AppButton(
                variant: .primary,
                text: "Preview Ranking",
                rightIcon: .arrowRight,
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
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
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

// MARK: - Preview Rank View

struct PreviewRankingResponseView: View {
    let question: Question
    let ranking: [PollResult]
    let onEdit: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(question.title)
                .font(.title)

            List {
                ForEach(ranking.indices, id: \.self) { index in
                    let result = ranking[index]
                    let answerText = result.answerIndex.map { question.variants[$0] } ?? "—"

                    HStack(spacing: 12) {
                        Text("\(index + 1).")
                            .font(.headline)
                            .frame(width: 30)

                        VerticalDivider()

                        Text(answerText)
                            .font(.body)
                            .foregroundColor(.textPrimary)
                            .padding(.leading, 12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.bgComponentBasePrimary)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .cornerRadius(12)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 0)

            Spacer()

            HStack(spacing: 12) {
                AppButton(
                    variant: .secondary,
                    text: "Edit",
                    leftIcon: .arrowLeft,
                    action: { onEdit() }
                )
                .controlSize(.large)

                AppButton(
                    variant: .primary,
                    text: "Submit",
                    rightIcon: .arrowRight,
                    action: { onSubmit() }
                )
                .controlSize(.large)
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }
}
