import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import SwiftUI

import Swoir
import Swoirenberg

@main
struct RarimeApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
//            AppView()
//                .environmentObject(AlertManager.shared)
//                .environmentObject(UserManager.shared)
//                .environmentObject(ConfigManager.shared)
//                .environmentObject(SecurityManager.shared)
//                .environmentObject(WalletManager.shared)
//                .environmentObject(SettingsManager.shared)
//                .environmentObject(PassportManager.shared)
//                .environmentObject(AppIconManager.shared)
//                .environmentObject(UpdateManager.shared)
//                .environmentObject(DecentralizedAuthManager.shared)
//                .environmentObject(CircuitDataManager.shared)
//                .environmentObject(NotificationManager.shared)
//                .environmentObject(ExternalRequestsManager.shared)
//                .environmentObject(InternetConnectionManager.shared)
            VStack {}
                .onAppear {
                    LoggerUtil.common.debug("App started")
                    
                    Task {
                        do {
                            let exampleCircuit = NSDataAsset(name: "exampleCircuit")!.data
                            
                            let inputsData = NSDataAsset(name: "inputs")!.data
                            let inputs = try JSONDecoder().decode(NoirInputs.self, from: inputsData)
                            
                            let swoir = Swoir(backend: Swoirenberg.self)
                            
                            let circuit = try swoir.createCircuit(manifest: exampleCircuit)
                            
                            try circuit.setupSrs()
                            
                            LoggerUtil.common.debug("inputs.toAnyMAp(): \(inputs.toAnyMAp().debugDescription)")
                            
                            let proof = try circuit.prove(inputs.toAnyMAp(), proof_type: "plonk", recursive: true)
                            
                            LoggerUtil.common.info("proof: \(proof.proof.fullHex)")
                        } catch {
                            LoggerUtil.common.error("failed to calculate plonk proof: \(error)")
                        }
                    }
                }
        }
    }
}

struct NoirInputs: Codable {
    let dg1, dg15, ec: [String]
    let icaoRoot: String
    let inclusionBrances, pk, reductionPk, sa: [String]
    let sig: [String]
    let skIdentity: String

    enum CodingKeys: String, CodingKey {
        case dg1, dg15, ec
        case icaoRoot = "icao_root"
        case inclusionBrances = "inclusion_brances"
        case pk
        case reductionPk = "reduction_pk"
        case sa, sig
        case skIdentity = "sk_identity"
    }
    
    func toAnyMAp() -> [String: Any] {
        var result: [String: Any] = [:]
        result["dg1"] = dg1
        result["dg15"] = dg15
        result["ec"] = ec
        result["icaoRoot"] = icaoRoot
        result["inclusionBrances"] = inclusionBrances
        result["pk"] = pk
        result["reductionPk"] = reductionPk
        result["sa"] = sa
        result["sig"] = sig
        result["skIdentity"] = skIdentity
        
        return result
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
