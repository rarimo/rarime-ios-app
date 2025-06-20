import SwiftUI
import Foundation
import Web3
import Alamofire

struct PollQRCodeView: View {
    @EnvironmentObject private var pollsViewModel: PollsViewModel
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    
    let qrCodeUrl: URL
    
    let onDismiss: () -> Void
    
    var body: some View {
        Group {
            if let poll = pollsViewModel.selectedPoll {
                PollView(
                    poll: poll,
                    onClose: onDismiss,
                    onVerification: {
                        onDismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            mainViewModel.selectedTab = .identity
                        }
                    }
                )
                .environmentObject(pollsViewModel)
            } else {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onAppear {
            Task { @MainActor in
                try await fetchPoll()
            }
        }
        // TODO: check if it works properly
        .onDisappear {
            pollsViewModel.selectedPoll = nil
        }
    }
    
    private func fetchPoll() async throws {
        do {
            let qrLinkService = QRLink(ConfigManager.shared.freedomTool.apiURL)
            let scanedQRLink = try await qrLinkService.scanQRLink(qrCodeUrl)
            
            pollsViewModel.selectedPoll = try await PollsService.fetchPoll(
                BigUInt(scanedQRLink.data.attributes.metadata.proposalId)
            )
        } catch {
            if let afError = error as? AFError, afError.responseCode != 200 {
                AlertManager.shared.emitError(.unknown(String(localized: "QR code is expired")))
            }
            onDismiss()
            throw error
        }
    }
}

#Preview {
    ZStack{}
        .dynamicSheet(isPresented: .constant(true), fullScreen: true) {
            PollQRCodeView(
                qrCodeUrl: URL(string: "rarime://external?type=voting&qr_code_url=https%3A%2F%2Fapi.stage.freedomtool.org%2Fi%2Fqr%2F45d5b08c-7bfb-4c49-91b7-8266cdf1f73b")!,
                onDismiss: {}
            )
            .environmentObject(PollsViewModel())
            .environmentObject(DecentralizedAuthManager())
            .environmentObject(UserManager())
        }
}
