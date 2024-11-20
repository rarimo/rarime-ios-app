import Foundation

enum Errors: Error {
    case openAPIErrors(OpenApiErrors)
    case invalidResponseBody
    case unknownServiceError
    case invalidHTTPStatusCode(Int)
    case serviceDown(URL?)
    case userCreationFailed
    case unknown(String?)
    case connectionUnstable
}

extension Errors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .openAPIErrors(let errors):
            return errors.localizedDescription
        case .invalidResponseBody:
            return String(localized: "Invalid response body")
        case .unknownServiceError:
            return String(localized: "Unknown service error")
        case .invalidHTTPStatusCode(let statusCode):
            return String(localized: "Invalid HTTP status code: \(statusCode)")
        case .serviceDown(let requestURL):
            let url = requestURL?.absoluteString ?? "nil"
            return String(localized: "One of our services is down, try again later. RequestURL=\(url)")
        case .userCreationFailed:
            return String(localized: "User creation failed")
        case .unknown(let message):
            return message ?? String(localized: "Unknown")
        case .connectionUnstable:
            return String(localized: "Internet connection is unstable")
        }
    }
}

extension Errors {
    var localizedDescription: String {
        return errorDescription ?? "Unknown error"
    }
}
