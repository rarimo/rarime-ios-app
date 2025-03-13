import SwiftUI
import Foundation
import Web3

struct VotingView: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    
    let proposalId: BigUInt
    
    let onDismiss: () -> Void
    
    var body: some View {
        Group {
            if let poll = pollsViewModel.selectedPoll {
                PollView(poll: poll, onClose: onDismiss)
                    .environmentObject(pollsViewModel)
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
        pollsViewModel.selectedPoll = try await PollsService.fetchPoll(proposalId)
    }
}

#Preview {
    ZStack{}
        .sheet(isPresented: .constant(true)) {
            VotingView(proposalId: .init(1), onDismiss: {})
        }
}
