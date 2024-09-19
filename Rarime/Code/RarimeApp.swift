import FirebaseCore
import FirebaseMessaging
import SwiftUI

@main
struct RarimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(AlertManager.shared)
                .environmentObject(UserManager.shared)
                .environmentObject(ConfigManager.shared)
                .environmentObject(SecurityManager.shared)
                .environmentObject(WalletManager.shared)
                .environmentObject(SettingsManager.shared)
                .environmentObject(PassportManager.shared)
                .environmentObject(AppIconManager.shared)
                .environmentObject(UpdateManager.shared)
                .environmentObject(DecentralizedAuthManager.shared)
                .environmentObject(CircuitDataManager.shared)
                .environmentObject(NotificationManager.shared)
                .environmentObject(ExternalRequestsManager.shared)
                .environmentObject(InternetConnectionManager.shared)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        LoggerUtil.common.info("User's FCM Token: \(fcmToken, privacy: .public)")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
