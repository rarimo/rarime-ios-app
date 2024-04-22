import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()

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
    }
}

#Preview {
    MainView()
}
