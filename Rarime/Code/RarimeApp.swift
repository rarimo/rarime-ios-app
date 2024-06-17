import SwiftUI

@main
struct RarimeApp: App {
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
        }
    }
}
