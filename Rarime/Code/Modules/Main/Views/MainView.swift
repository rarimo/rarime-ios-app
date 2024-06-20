import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userManager: UserManager
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var isRewardsSheetPresented = false
    
    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: HomeView(isRewardsSheetPresented: $isRewardsSheetPresented)
                case .wallet: WalletView()
                case .rewards: RewardsView()
                case .profile: ProfileView()
            }
        }
        .environmentObject(viewModel)
        .onChange(of: viewModel.selectedTab) { selectedTab in
            if userManager.user?.status == .unscanned, selectedTab == .rewards {
                self.isRewardsSheetPresented = true
                
                self.viewModel.selectedTab = .home
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
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
