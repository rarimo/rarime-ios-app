import SwiftUI

private enum ExternalRequest: Equatable {
    case proofRequest(id: String, proofParamsUrl: URL, callbackUrl: URL)

    var title: LocalizedStringResource {
        switch self {
        case .proofRequest: "Proof Request"
        }
    }
}

struct ExternalRequestsView: View {
    @EnvironmentObject private var userManager: UserManager

    @State private var isSheetPresented = false
    @State private var externalRequest: ExternalRequest? = nil

    var body: some View {
        ZStack {}
            .dynamicSheet(isPresented: $isSheetPresented, title: externalRequest?.title) {
                switch externalRequest {
                case let .proofRequest(id, proofParamsUrl, callbackUrl):
                    ProofRequestView(
                        requestId: id,
                        proofParamsUrl: proofParamsUrl,
                        callbackUrl: callbackUrl,
                        onSuccess: { isSheetPresented = false },
                        onDismiss: { isSheetPresented = false }
                    )
                default:
                    EmptyView()
                }
            }
            .onChange(of: isSheetPresented) { isPresented in
                if !isPresented {
                    externalRequest = nil
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
        guard let requestId = params.first(where: { $0.name == "id" })?.value,
              let rawProofParamsUrl = params.first(where: { $0.name == "proof_params_url" })?.value,
              let rawCallbackUrl = params.first(where: { $0.name == "callback_url" })?.value,
              let proofParamsUrl = URL(string: rawProofParamsUrl),
              let callbackUrl = URL(string: rawCallbackUrl)
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

        externalRequest = .proofRequest(id: requestId, proofParamsUrl: proofParamsUrl, callbackUrl: callbackUrl)
        isSheetPresented = true
    }
}

private struct ProofRequestView: View {
    let requestId: String
    let proofParamsUrl: URL
    let callbackUrl: URL
    let onSuccess: () -> Void
    let onDismiss: () -> Void

    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                makeItemRow(title: "Request ID", value: requestId)
                makeItemRow(title: "Proof Params URL", value: proofParamsUrl.absoluteString)
                makeItemRow(title: "Callback URL", value: callbackUrl.absoluteString)
            }
            VStack(spacing: 4) {
                AppButton(text: "Generate Proof", action: generateProof)
                    .disabled(isSubmitting)
                    .controlSize(.large)
                AppButton(
                    variant: .tertiary,
                    text: "Cancel",
                    action: onDismiss
                )
                .disabled(isSubmitting)
                .controlSize(.large)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private func makeItemRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .body3()
            Spacer()
            Text(value)
                .subtitle4()
                .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(.textPrimary)
    }

    private func generateProof() {
        Task { @MainActor in
            isSubmitting = true
            defer { isSubmitting = false }

            do {
                // TODO: Generate proof
                try await Task.sleep(nanoseconds: 3_000_000_000)
                AlertManager.shared.emitSuccess("Proof generated successfully")
                onSuccess()
            } catch {
                AlertManager.shared.emitError(.unknown("Failed to generate proof"))
                LoggerUtil.common.error("Failed to generate proof: \(error)")
            }
        }
    }
}

#Preview {
    ZStack {}
        .dynamicSheet(isPresented: .constant(true), title: "Proof Request") {
            ProofRequestView(
                requestId: "123",
                proofParamsUrl: URL(string: "https://example.com")!,
                callbackUrl: URL(string: "https://example.com")!,
                onSuccess: {},
                onDismiss: {}
            )
        }
}
