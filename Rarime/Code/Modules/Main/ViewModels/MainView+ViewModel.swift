import SwiftUI

enum MainTabs: Int, CaseIterable {
//    case home, identity, scanQr, wallet, profile
    case home, identity, scanQr, profile

    var iconName: String {
        switch self {
        case .home: return Icons.homeLine
        case .identity: return Icons.passportLine
        case .scanQr: return Icons.qrScan2Line
//        case .wallet: return Icons.walletLine
        case .profile: return Icons.userLine
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.homeFill
        case .identity: return Icons.passportFill
        case .scanQr: return Icons.qrScan2Line
//        case .wallet: return Icons.walletFill
        case .profile: return Icons.userFill
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var selectedTab: MainTabs = .home
        @Published var isQrCodeScanSheetShown = false

        func selectTab(_ tab: MainTabs) {
            selectedTab = tab
        }
    }
}
