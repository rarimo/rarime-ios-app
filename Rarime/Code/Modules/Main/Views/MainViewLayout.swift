import SwiftUI

struct MainViewLayout<Content: View>: View {
    @EnvironmentObject var mainViewModel: MainView.ViewModel
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            NavBarView(
                selectedTab: $mainViewModel.selectedTab,
                isQrCodeScanSheetShown: $mainViewModel.isQrCodeScanSheetShown
            )
            .background(.bgPrimary)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(NotificationManager())
        .environmentObject(ExternalRequestsManager())
}
