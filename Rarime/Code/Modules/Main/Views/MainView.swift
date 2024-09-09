import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userManager: UserManager
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: HomeView()
                case .profile: ProfileView()
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    let userManager = UserManager.shared
    
    return MainView()
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
