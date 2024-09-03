import SwiftUI

struct MainView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var userManager: UserManager
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: HomeView()
                case .wallet: WalletView()
                case .rewards: RewardsView()
                case .profile: ProfileView()
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
    
    return MainView()
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(NotificationManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
