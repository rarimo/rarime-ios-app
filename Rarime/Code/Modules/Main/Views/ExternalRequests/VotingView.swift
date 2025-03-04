import SwiftUI
import Foundation
import Web3

struct VotingView: View {
    let proposalId: BigUInt
    let onDismiss: () -> Void
    
    @StateObject var pollsViewModel = PollsViewModel()
    
    var body: some View {
        Group {
            if let poll = pollsViewModel.selectedPoll {
                PollView(poll: poll, onClose: onDismiss)
            } else {
                ProgressView()
            }
        }
        .environmentObject(pollsViewModel)
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
