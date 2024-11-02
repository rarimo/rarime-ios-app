import Foundation
import SwiftUI

enum RarimeUrlHosts: String {
    case external
    case crossapps
}

enum ExternalRequestTypes: String, Codable {
    case proofRequest = "proof-request"
    case lightVerification = "light-verification"
}

enum ExternalRequests: Equatable {
    case proofRequest(proofParamsUrl: URL)
    case lightVerification(verificationParamsUrl: URL)
}

class ExternalRequestsManager: ObservableObject {
    static let shared = ExternalRequestsManager()

    @Published private(set) var request: ExternalRequests? = nil

    func handleRarimeUrl(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let params = components.queryItems
        else {
            LoggerUtil.common.error("Invalid RariMe app URL: \(url.absoluteString, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid RariMe app URL"))
            return
        }

        switch url.host {
        case RarimeUrlHosts.external.rawValue:
            handleExternalRequest(params: params)
        case RarimeUrlHosts.crossapps.rawValue:
            handleCrossAppsRequest(params: params)
        default:
            LoggerUtil.common.error("Invalid RariMe URL host: \(url.host ?? "nil", privacy: .public)")
        }
    }

    private func handleCrossAppsRequest(params: [URLQueryItem]) {
        Task { @MainActor in
            do {
                try await _handleCrossAppsRequest(params)
            } catch {
                LoggerUtil.common.debug("Failed to handle crossapps request: \(error, privacy: .public)")
            }
        }
    }

    private func _handleCrossAppsRequest(_ params: [URLQueryItem]) async throws {
        guard let passport = PassportManager.shared.passport else {
            throw "invalid passport"
        }

        guard let eventData = params.first(where: { $0.name == "event_data" })?.value else {
            throw "invalid event data"
        }

        guard var responseUrl = params.first(where: { $0.name == "response_url" })?.value else {
            throw "invalid response url"
        }

        let proof = try await UserManager.shared.generateCrossAppQueryProof(passport: passport, eventData: eventData)

        responseUrl = responseUrl + "?proof=\(proof.json.fullHex)"

        let url = URL(string: responseUrl)!
        await UIApplication.shared.open(url, options: [:], completionHandler: nil)
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

        setRequest(.proofRequest(proofParamsUrl: proofParamsUrl))
    }

    private func handleLightVerificationRequest(params: [URLQueryItem]) {
        guard let rawProofParamsUrl = params.first(where: { $0.name == "proof_params_url" })?.value?.removingPercentEncoding,
              let proofParamsUrl = URL(string: rawProofParamsUrl)
        else {
            LoggerUtil.common.error("Invalid light verification request URL: \(params, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid light verification request URL"))
            return
        }

        setRequest(.lightVerification(verificationParamsUrl: proofParamsUrl))
    }

    func setRequest(_ request: ExternalRequests) {
        self.request = request
    }

    func resetRequest() {
        request = nil
    }
}
