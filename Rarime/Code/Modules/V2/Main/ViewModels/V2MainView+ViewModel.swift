import SwiftUI

enum V2MainTabs: Int, CaseIterable {
    case home, identity, scanQr, wallet, profile

    var iconName: String {
        switch self {
        case .home: return Icons.homeLine
        case .identity: return Icons.passportLine
        case .scanQr: return Icons.qrScan2Line
        case .wallet: return Icons.walletLine
        case .profile: return Icons.userLine
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.homeFill
        case .identity: return Icons.passportFill
        case .scanQr: return Icons.qrScan2Line
        case .wallet: return Icons.walletFill
        case .profile: return Icons.userFill
        }
    }
}

extension V2MainView {
    class ViewModel: ObservableObject {
        @Published var selectedTab: V2MainTabs = .home
        @Published var isRewardsSheetPresented = false

        func selectTab(_ tab: V2MainTabs) {
            selectedTab = tab
        }
    }
}
