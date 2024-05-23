import Foundation

enum Errors: Error {
    case openAPIErrors(OpenApiErrors)
    case invalidResponseBody
    case unknownServiceError
    case invalidHTTPStatusCode(Int)
    case serviceDown(URL?)
    case userCreationFailed
    case unknown
}

extension Errors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .openAPIErrors(let errors):
            return NSLocalizedString(errors.localizedDescription, comment: "")
        case .invalidResponseBody:
            return NSLocalizedString("Invalid response body", comment: "")
        case .unknownServiceError:
            return NSLocalizedString("Unknown service error", comment: "")
        case .invalidHTTPStatusCode(let statusCode):
            return String(format: NSLocalizedString("Invalid HTTP status code: %d", comment: ""), statusCode)
        case .serviceDown(let requestURL):
            let url = requestURL?.absoluteString ?? "nil"
            
            return String(format: NSLocalizedString("One of our services is down, try again later. RequestURL=%@", comment: ""), url)
        case .userCreationFailed:
            return NSLocalizedString("User creation failed", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "")
        }
    }
}

extension Errors {
    var localizedDescription: String {
        switch self {
        case .openAPIErrors(let errors):
            return NSLocalizedString(errors.localizedDescription, comment: "")
        case .invalidResponseBody:
            return NSLocalizedString("Invalid response body", comment: "")
        case .unknownServiceError:
            return NSLocalizedString("Unknown service error", comment: "")
        case .invalidHTTPStatusCode(let statusCode):
            return String(format: NSLocalizedString("Invalid HTTP status code: %d", comment: ""), statusCode)
        case .serviceDown(_):
            return NSLocalizedString("One of our services is down, try again later", comment: "")
        case .userCreationFailed:
            return NSLocalizedString("User creation failed", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "")
        }
    }
}
