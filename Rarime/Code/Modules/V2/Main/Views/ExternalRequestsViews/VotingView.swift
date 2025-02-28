import SwiftUI
import Foundation
import Web3

struct VotingView: View {
    let proposalId: BigUInt
    let onSuccess: () -> Void
    let onDismiss: () -> Void
    
    @State private var poll: Poll? = nil

    private var totalParticipants: Int {
        guard let poll = poll else { return 0 }
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
    var body: some View {
        Group {
            if poll != nil {
                EmptyView()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task { @MainActor in
                try await fetchPoll()
            }
        }
    }
    
    private func fetchPoll() async throws {
        poll = try await PollsService.fetchPoll(proposalId)
    }
}

#Preview {
    VotingView(proposalId: .init(1), onSuccess: {}, onDismiss: {})
}
