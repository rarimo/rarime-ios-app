import CoreData
import Foundation

struct PushNotificationRaw: Codable {
    let aps: APS
    let type: PushNotificationType?
    let content: String?
    
    struct APS: Codable {
        let alert: Alert
        
        struct Alert: Codable {
            let title: String
            let body: String
        }
    }
    
    init(_ userInfo: [AnyHashable: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        
        self = try JSONDecoder().decode(PushNotificationRaw.self, from: data)
    }
}

extension PushNotificationRaw {
    enum PushNotificationType: String, Codable {
        case reward
        case universal
    }
}

@objc(PushNotification)
public class PushNotification: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var receivedAt: Date?
    @NSManaged public var isRead: Bool
    @NSManaged public var type: String?
    @NSManaged public var content: String?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PushNotification> {
        return NSFetchRequest<PushNotification>(entityName: "PushNotification")
    }
}
