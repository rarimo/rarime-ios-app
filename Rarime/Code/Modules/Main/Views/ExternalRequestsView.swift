import SwiftUI

struct ExternalRequestsView: View {
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject private var userManager: UserManager

    @State private var isSheetPresented = false

    private var sheetTitle: LocalizedStringResource {
        switch externalRequestsManager.request {
        case .proofRequest: "Proof Request"
        case .lightVerification: "Light Verification"
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
                case let .lightVerification(verificationParamsUrl):
                    LightVerificationView(
                        verificationParamsUrl: verificationParamsUrl,
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
