import SwiftUI

struct MainView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home:
                    HomeView()
                case .wallet:
                    WalletView()
                case .rewards:
                    RewardsView()
                case .profile:
                    ProfileView()
            }
        }
        .environmentObject(appViewModel)
        .environmentObject(viewModel)
    }
}

#Preview {
    MainView()
        .environmentObject(AppView.ViewModel())
}
