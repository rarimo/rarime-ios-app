import Foundation

enum ExternalRequestType: String, Codable {
    case proofRequest = "proof-request"
}

enum ExternalRequest: Equatable {
    case proofRequest(proofParamsUrl: URL)
}

class ExternalRequestsManager: ObservableObject {
    static let shared = ExternalRequestsManager()

    @Published private(set) var request: ExternalRequest? = nil

    func handleRarimeUrl(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let params = components.queryItems
        else {
            LoggerUtil.common.error("Invalid RariMe app URL: \(url.absoluteString)")
            AlertManager.shared.emitError(.unknown("Invalid RariMe app URL"))
            return
        }

        switch url.host {
        case "external":
            handleExternalRequest(params: params)
        default:
            LoggerUtil.common.error("Invalid RariMe URL host: \(url.host ?? "nil")")
        }
    }

    private func handleExternalRequest(params: [URLQueryItem]) {
        guard let type = params.first(where: { $0.name == "type" })?.value
        else {
            LoggerUtil.common.error("Invalid external request URL: \(params)")
            AlertManager.shared.emitError(.unknown("Invalid external request URL"))
            return
        }

        switch type {
        case ExternalRequestType.proofRequest.rawValue:
            handleProofRequest(params: params)
        default:
            LoggerUtil.common.error("Invalid external request type: \(type)")
        }
    }

    private func handleProofRequest(params: [URLQueryItem]) {
        guard let rawDataUrl = params.first(where: { $0.name == "data_url" })?.value?.removingPercentEncoding,
              let dataUrl = URL(string: rawDataUrl)
        else {
            LoggerUtil.common.error("Invalid proof request URL: \(params)")
            AlertManager.shared.emitError(.unknown("Invalid proof request URL"))
            return
        }

        if UserManager.shared.registerZkProof == nil {
            LoggerUtil.common.error("Proof requests are not available, passport is not registered")
            AlertManager.shared.emitError(.unknown("Proof requests are not available. Please create your identity first."))
            return
        }

        setRequest(.proofRequest(proofParamsUrl: dataUrl))
    }

    func setRequest(_ request: ExternalRequest) {
        self.request = request
    }

    func resetRequest() {
        request = nil
    }
}
