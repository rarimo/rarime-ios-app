import Foundation

struct UniversalNotificationContent: Codable {
    let eventType: String?
    let nationality: String?
    let userStatuses: [UniversalNotificationContent.UserStatus]?
    let newSupportedCircuit: String?

    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case nationality
        case userStatuses = "user_statuses"
        case newSupportedCircuit = "new_supported_circuit"
    }
}

extension UniversalNotificationContent {
    enum UserStatus: String, Codable {
        case unscanned
        case waitlist
        case verified
    }
}
