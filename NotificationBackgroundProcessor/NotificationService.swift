import SwiftUI
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent {
            guard let pushNotification = try? PushNotificationRaw(bestAttemptContent.userInfo) else {
                contentHandler(bestAttemptContent)
                
                return
            }
            
            if pushNotification.type == .universal {
                do {
                    let shouldRegisterNotification = try handleUniversalNotification(pushNotification)
                    if !shouldRegisterNotification {
                        return
                    }
                } catch {
                    LoggerUtil.common.error("Failed to handle universal notification: \(error)")
                }
            }
            
            try? NotificationManager.shared.saveNotification(pushNotification)
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func handleUniversalNotification(_ notification: PushNotificationRaw) throws -> Bool {
        guard let content = notification.content else {
            throw "content is nil"
        }
        
        let universalNotificationContent = try JSONDecoder().decode(UniversalNotificationContent.self, from: content.data(using: .utf8) ?? Data())
        
        let userStatus = figureOutUserStatus()
        
        if let eventType = universalNotificationContent.eventType {
            if userStatus == .unscanned {
                return false
            }
        }
        
        if let requiredNationality = universalNotificationContent.nationality {
            if requiredNationality.lowercased() != PassportManager.shared.passport?.nationality.lowercased() {
                return false
            }
        }
        
        if let requiredUserStatuses = universalNotificationContent.userStatuses {
            if !requiredUserStatuses.contains(where: { $0 == userStatus }) {
                return false
            }
        }
        
        if let newSupportedCircuit = universalNotificationContent.newSupportedCircuit {
            if userStatus != .waitlist {
                return false
            }
            
            guard let passport = PassportManager.shared.passport else {
                return false
            }
            
            guard let registerIdentityCircuitType = try? passport.getRegisterIdentityCircuitType() else {
                return false
            }
            
            guard let registerIdentityCircuitName = registerIdentityCircuitType.buildName() else {
                return false
            }
            
            if registerIdentityCircuitName != newSupportedCircuit {
                return false
            }
        }
        
        return true
    }
    
    func figureOutUserStatus() -> UniversalNotificationContent.UserStatus {
        var hasScannedPassport = (try? AppKeychain.containsValue(.passport)) ?? false
        var hasRegistrationProof = (try? AppKeychain.containsValue(.registerZkProof)) ?? false
        
        if hasScannedPassport && hasRegistrationProof {
            return .verified
        }
        
        if hasScannedPassport {
            return .waitlist
        }
        
        return .unscanned
    }
}
