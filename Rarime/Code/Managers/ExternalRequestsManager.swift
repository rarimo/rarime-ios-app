import Foundation
import Web3

enum RarimeUrlHosts: String {
    case external
}

enum ExternalRequestTypes: String, Codable {
    case proofRequest = "proof-request"
    case lightVerification = "light-verification"
    case voting
}

enum ExternalRequests: Equatable {
    case proofRequest(proofParamsUrl: URL, urlQueryParams: [URLQueryItem])
    case lightVerification(verificationParamsUrl: URL, urlQueryParams: [URLQueryItem])
    case voting(qrCodeUrl: URL)
}

class ExternalRequestsManager: ObservableObject {
    static let shared = ExternalRequestsManager()

    @Published private(set) var request: ExternalRequests? = nil

    func handleUrl(_ url: URL) {
        url.path.hasPrefix("/r/") ? handleRefferalCode(url) : handleRarimeUrl(url)
    }

    func handleRarimeUrl(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let params = components.queryItems
        else {
            LoggerUtil.common.error("Invalid RariMe app URL: \(url.absoluteString, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid RariMe app URL"))
            return
        }

        if isValidExternalUrl(url) {
            handleExternalRequest(params: params)
            return
        }

        LoggerUtil.common.error("Invalid RariMe URL host: \(url.host ?? "nil", privacy: .public)")
    }

    private func handleRefferalCode(_ url: URL) {
        let code = String(url.path.dropFirst(3))
        AppUserDefaults.shared.deferredReferralCode = code
        UserManager.shared.user?.deferredReferralCode = code
        LoggerUtil.common.info("Deferred referral code set: \(code, privacy: .public)")
    }

    private func handleExternalRequest(params: [URLQueryItem]) {
        guard let type = params.first(where: { $0.name == "type" })?.value
        else {
            LoggerUtil.common.error("Invalid external request URL: \(params, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid external request URL"))
            return
        }

        switch type {
        case ExternalRequestTypes.proofRequest.rawValue:
            handleProofRequest(params: params)
        case ExternalRequestTypes.lightVerification.rawValue:
            handleLightVerificationRequest(params: params)
        case ExternalRequestTypes.voting.rawValue:
            handleVotingRequest(params: params)
        default:
            LoggerUtil.common.error("Invalid external request type: \(type, privacy: .public)")
        }
    }

    private func handleProofRequest(params: [URLQueryItem]) {
        guard let rawProofParamsUrl = params.first(where: { $0.name == "proof_params_url" })?.value?.removingPercentEncoding,
              let proofParamsUrl = URL(string: rawProofParamsUrl)
        else {
            LoggerUtil.common.error("Invalid proof request URL: \(params, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid proof request URL"))
            return
        }

        if UserManager.shared.registerZkProof == nil {
            LoggerUtil.common.error("Proof requests are not available, passport is not registered")
            AlertManager.shared.emitError(.unknown("Proof requests are not available. Please create your identity first."))
            return
        }

        setRequest(.proofRequest(proofParamsUrl: proofParamsUrl, urlQueryParams: params))
    }

    private func handleLightVerificationRequest(params: [URLQueryItem]) {
        guard let rawProofParamsUrl = params.first(where: { $0.name == "proof_params_url" })?.value?.removingPercentEncoding,
              let proofParamsUrl = URL(string: rawProofParamsUrl)
        else {
            LoggerUtil.common.error("Invalid light verification request URL: \(params, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid light verification request URL"))
            return
        }

        setRequest(.lightVerification(verificationParamsUrl: proofParamsUrl, urlQueryParams: params))
    }

    private func isValidExternalUrl(_ url: URL) -> Bool {
        if url.scheme == "rarime", url.host == "external" {
            return true
        }

        if url.scheme == "https", let host = url.host, ["app.rarime.com", "app.stage.rarime.com"].contains(host), url.path.hasPrefix("/external") {
            return true
        }

        return false
    }

    private func handleVotingRequest(params: [URLQueryItem]) {
        guard let rawQrCodeUrl = params.first(where: { $0.name == "qr_code_url" })?.value?.removingPercentEncoding,
              let qrCodeUrl = URL(string: rawQrCodeUrl)
        else {
            LoggerUtil.common.error("Invalid QR Code URL: \(params, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid QR Code URL"))
            return
        }

        setRequest(.voting(qrCodeUrl: qrCodeUrl))
    }

    func setRequest(_ request: ExternalRequests) {
        self.request = request
    }

    func resetRequest() {
        request = nil
    }
}
