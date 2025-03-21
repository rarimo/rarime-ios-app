import SwiftUI

struct V2MainView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager

    @StateObject private var viewModel = ViewModel()
    @StateObject private var pollsViewModel = PollsViewModel()
    @StateObject private var passportViewModel = PassportViewModel()

    var body: some View {
        ZStack {
            switch viewModel.selectedTab {
                case .home: V2HomeView()
                case .identity: IdentityView()
                case .scanQr: ScanQRView(
                        // TODO: change routing after design impl
                        onBack: { viewModel.selectedTab = .home },
                        onScan: processQrCode
                    )
                case .wallet: WalletView()
                case .profile: ProfileView()
            }
            ExternalRequestsView()
        }
        .dynamicSheet(isPresented: $viewModel.isQrCodeScanSheetShown, fullScreen: true) {
            ScanQRView(
                onBack: { viewModel.isQrCodeScanSheetShown = false },
                onScan: processQrCode
            )
        }
        .environmentObject(viewModel)
        .environmentObject(pollsViewModel)
        .environmentObject(passportViewModel)
        .onAppear(perform: checkNotificationPermission)
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

    return V2MainView()
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
