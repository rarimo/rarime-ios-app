import Foundation

struct ClaimableNotificationContent: Codable {
    let eventName: String
    
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
    }
}
