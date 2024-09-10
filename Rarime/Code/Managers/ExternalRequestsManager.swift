import Foundation

enum ExternalRequest: Equatable {
    case proofRequest(proofParamsUrl: URL)
}

class ExternalRequestsManager: ObservableObject {
    static let shared = ExternalRequestsManager()

    @Published private(set) var request: ExternalRequest? = nil

    func setRequest(_ request: ExternalRequest) {
        self.request = request
    }

    func resetRequest() {
        request = nil
    }
}
