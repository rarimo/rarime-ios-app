import SwiftUI

@main
struct RarimeApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(UserManager.shared)
                .environmentObject(ConfigManager.shared)
                .environmentObject(SecurityManager.shared)
                .environmentObject(WalletManager.shared)
                .environmentObject(SettingsManager.shared)
                .environmentObject(PassportManager.shared)
                .environmentObject(CircuitDataManager.shared)
        }
    }
}
