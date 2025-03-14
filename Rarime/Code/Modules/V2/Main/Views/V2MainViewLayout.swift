import SwiftUI

struct V2MainViewLayout<Content: View>: View {
    @EnvironmentObject var mainViewModel: V2MainView.ViewModel
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0, content: {
                ZStack(alignment: .top) {
                    TransparentBlurView(removeAllFilters: false)
                        .ignoresSafeArea(edges: .bottom)
                        .background(.bgBlur)
                    V2NavBarView(selectedTab: $mainViewModel.selectedTab)
                }
                .frame(height: 70)
            })
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
