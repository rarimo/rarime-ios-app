import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()
    @StateObject private var walletViewModel = WalletViewModel()

    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: HomeView()
                case .wallet: WalletView()
                case .rewards: RewardsView()
                case .profile: ProfileView()
            }
        }
        .environmentObject(viewModel)
        .environmentObject(walletViewModel)
    }
}

#Preview {
    MainView()
        .environmentObject(AppView.ViewModel())
}
