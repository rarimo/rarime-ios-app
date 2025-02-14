import SwiftUI

struct V2MainView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var userManager: UserManager
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: V2HomeView()
                case .passport: WalletView()
                case .scanQr: WalletView()
                case .wallet: WalletView()
                case .profile: WalletView()
            }
            ExternalRequestsView()
        }
        .environmentObject(viewModel)
        .onAppear(perform: checkNotificationPermission)
    }
    
    func checkNotificationPermission() {
        Task { @MainActor in
            if !(await notificationManager.isAuthorized()) {
                try? await notificationManager.request()
            }
        }
    }
}

#Preview {
    let userManager = UserManager.shared
    
    return V2MainView()
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(NotificationManager())
        .environmentObject(ExternalRequestsManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
