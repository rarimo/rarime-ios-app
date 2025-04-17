import SwiftUI

struct ExternalRequestsView: View {
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject private var userManager: UserManager

    @State private var isSheetPresented = false

    var body: some View {
        ZStack {}
            .dynamicSheet(isPresented: $isSheetPresented, fullScreen: true) {
                switch externalRequestsManager.request {
                case let .proofRequest(proofParamsUrl, urlQueryParams):
                    ProofRequestView(
                        proofParamsUrl: proofParamsUrl,
                        onSuccess: {
                            isSheetPresented = false

                            handleRedirect(urlQueryParams)
                        },
                        onDismiss: { isSheetPresented = false }
                    )
                case let .lightVerification(verificationParamsUrl, urlQueryParams):
                    LightVerificationView(
                        verificationParamsUrl: verificationParamsUrl,
                        onSuccess: {
                            isSheetPresented = false

                            handleRedirect(urlQueryParams)
                        },
                        onDismiss: { isSheetPresented = false }
                    )
                case let .voting(qrCodeUrl):
                    PollQRCodeView(
                        qrCodeUrl: qrCodeUrl,
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
                externalRequestsManager.handleUrl(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else { return }
                externalRequestsManager.handleUrl(url)
            }
    }

    func handleRedirect(_ urlQueryParams: [URLQueryItem]) {
        guard let redirectUri = urlQueryParams.first(where: { $0.name == "redirect_uri" })?.value else {
            return
        }

        guard let url = URL(string: redirectUri) else {
            return
        }

        UIApplication.shared.open(url)
    }
}
