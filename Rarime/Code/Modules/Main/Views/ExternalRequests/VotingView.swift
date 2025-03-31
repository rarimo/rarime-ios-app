import SwiftUI
import Foundation
import Web3

struct VotingView: View {
    @EnvironmentObject private var pollsViewModel: PollsViewModel
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var userManager: UserManager
    
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
        guard let user = userManager.user else { throw "failed to get user" }
        let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)

        let qrLinkApi = VotingQRCode(ConfigManager.shared.api.votingRelayerURL)
        let qrCode = try await qrLinkApi.getLink(accessJwt, String(proposalId))
        
        if !qrCode.data.attributes.active { throw "QR code is expired" }
        
        pollsViewModel.selectedPoll = try await PollsService.fetchPoll(proposalId)
    }
}

#Preview {
    ZStack{}
        .dynamicSheet(isPresented: .constant(true), fullScreen: true) {
            VotingView(proposalId: .init(1), onDismiss: {})
        }
}
