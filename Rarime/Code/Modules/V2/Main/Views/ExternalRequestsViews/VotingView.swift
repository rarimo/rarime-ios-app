import SwiftUI
import Foundation
import Web3

struct VotingView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var decenralizedAuthManager: DecentralizedAuthManager
    
    let proposalId: BigUInt
    let onSuccess: () -> Void
    let onDismiss: () -> Void
    
    @State private var poll: Poll? = nil
    @State private var isSubmitting = false

    private var totalParticipants: Int {
        guard let poll = poll else { return 0 }
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
    var body: some View {
        ZStack {
            if let poll = poll {
                PollView(poll: poll, onClose: onDismiss)
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


