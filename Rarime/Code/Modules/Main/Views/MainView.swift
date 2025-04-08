import SwiftUI

struct MainView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager

    @StateObject private var viewModel = ViewModel()
    @StateObject private var passportViewModel = PassportViewModel()
    @StateObject private var pollsViewModel = PollsViewModel()

    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: HomeView()
                case .identity: IdentityView()
                case .scanQr: EmptyView()
//                case .wallet: WalletView()
                case .profile: ProfileView()
            }
            ExternalRequestsView()
        }
        .environmentObject(viewModel)
        .environmentObject(passportViewModel)
        .environmentObject(pollsViewModel)
        .onAppear(perform: checkNotificationPermission)
        .dynamicSheet(isPresented: $viewModel.isQrCodeScanSheetShown, fullScreen: true) {
            ScanQRView(
                onBack: { viewModel.isQrCodeScanSheetShown = false },
                onScan: processQrCode
            )
        }
    }

    func checkNotificationPermission() {
        Task { @MainActor in
            if !(await notificationManager.isAuthorized()) {
                try? await notificationManager.request()
            }
        }
    }

    func processQrCode(_ code: String) {
        guard let qrCodeUrl = URL(string: code) else {
            LoggerUtil.common.error("Invalid QR code: \(code, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid QR code"))
            return
        }

        externalRequestsManager.handleRarimeUrl(qrCodeUrl)
        viewModel.isQrCodeScanSheetShown = false
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
        .environmentObject(ExternalRequestsManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
