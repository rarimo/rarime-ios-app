import SwiftUI

struct ExternalRequestsView: View {
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject private var userManager: UserManager

    @State private var isSheetPresented = false

    private var sheetTitle: LocalizedStringResource {
        switch externalRequestsManager.request {
        case .proofRequest: "Proof Request"
        default: ""
        }
    }

    var body: some View {
        ZStack {}
            .dynamicSheet(isPresented: $isSheetPresented, title: sheetTitle) {
                switch externalRequestsManager.request {
                case let .proofRequest(proofParamsUrl):
                    ProofRequestView(
                        proofParamsUrl: proofParamsUrl,
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
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let params = components.queryItems
                else {
                    LoggerUtil.common.error("Invalid RariMe app URL: \(url.absoluteString)")
                    AlertManager.shared.emitError(.unknown("Invalid RariMe app URL"))
                    return
                }

                switch url.host {
                case "proof-request":
                    handleProofRequest(params: params)
                default:
                    LoggerUtil.common.error("Invalid RariMe URL host: \(url.host ?? "nil")")
                }
            }
    }

    private func handleProofRequest(params: [URLQueryItem]) {
        guard let rawProofParamsUrl = params.first(where: { $0.name == "proof_params_url" })?.value,
              let proofParamsUrl = URL(string: rawProofParamsUrl)
        else {
            LoggerUtil.common.error("Invalid proof request URL: \(params)")
            AlertManager.shared.emitError(.unknown("Invalid proof request URL"))
            return
        }

        if userManager.registerZkProof == nil {
            LoggerUtil.common.error("Proof requests are not available, passport is not registered")
            AlertManager.shared.emitError(.unknown("Proof requests are not available. Please create your identity first."))
            return
        }

        externalRequestsManager.setRequest(.proofRequest(proofParamsUrl: proofParamsUrl))
    }
}
