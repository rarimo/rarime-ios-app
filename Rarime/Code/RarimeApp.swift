import AppsFlyerLib
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
        
        AppsFlyerLib.shared().appsFlyerDevKey = ConfigManager.shared.appsFlyer.devKey
        AppsFlyerLib.shared().appleAppID = ConfigManager.shared.appsFlyer.appId
        AppsFlyerLib.shared().deepLinkDelegate = self
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
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

extension AppDelegate: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        if result.status != .found {
            return
        }

        guard let deepLinkObj: DeepLink = result.deepLink else {
            LoggerUtil.common.log("[AFSDK] Could not extract deep link object")
            return
        }

        if deepLinkObj.isDeferred == true {
            let code = deepLinkObj.deeplinkValue ?? ""
            AppUserDefaults.shared.deferredReferralCode = code
            UserManager.shared.user?.deferredReferralCode = code
            LoggerUtil.common.info("Deferred referral code set: \(deepLinkObj.deeplinkValue ?? "", privacy: .public)")
        }
    }
}
