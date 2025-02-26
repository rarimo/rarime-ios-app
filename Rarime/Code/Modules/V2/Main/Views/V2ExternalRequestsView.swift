import SwiftUI
import Web3

struct V2ExternalRequestsView: View {
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject private var userManager: UserManager

    @State private var isSheetPresented = false

    var body: some View {
        ZStack {}
            .sheet(isPresented: $isSheetPresented) {
                switch externalRequestsManager.request {
                case let .voting(proposalId):
                    VotingView(
                        proposalId: proposalId,
                        onSuccess: { isSheetPresented = false },
                        onDismiss: { isSheetPresented = false }
                    )

                default:
                    EmptyView()
                }
            }
            .onChange(of: externalRequestsManager.request) { request in
                if request != nil {
                    isSheetPresented = true
                }
            }
            .onChange(of: isSheetPresented) { isPresented in
                if !isPresented {
                    externalRequestsManager.resetRequest()
                }
            }
            .onOpenURL { url in
                externalRequestsManager.handleRarimeUrl(url)
            }
    }
}
