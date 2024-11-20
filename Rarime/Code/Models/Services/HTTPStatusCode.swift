import Foundation

enum HTTPStatusCode: String {
    case ok = "200"
    case created = "201"
    case notFound = "404"
    case conflict = "409"
    case tooManyRequests = "429"
}
