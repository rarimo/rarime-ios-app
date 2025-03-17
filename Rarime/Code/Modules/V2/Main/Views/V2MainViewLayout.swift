import SwiftUI

struct V2MainViewLayout<Content: View>: View {
    @EnvironmentObject var mainViewModel: V2MainView.ViewModel
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            V2NavBarView(selectedTab: $mainViewModel.selectedTab)
                .background {
                    ZStack {
                        Color.bgBlur
                        TransparentBlurView(removeAllFilters: false)
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                }
        }
    }
}

#Preview {
    V2HomeView()
        .environmentObject(V2MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(NotificationManager())
        .environmentObject(ExternalRequestsManager())
}
