import SwiftUI

@main
struct RarimeApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(ConfigManager.shared)
                .environmentObject(SecurityManager.shared)
                .environmentObject(IdentityManager.shared)
                .environmentObject(WalletManager.shared)
                .environmentObject(PassportManager.shared)
                .environmentObject(SettingsManager.shared)
                .environmentObject(UserManager.shared)
                .environmentObject(CircuitDataManager.shared)
        }
    }
}
