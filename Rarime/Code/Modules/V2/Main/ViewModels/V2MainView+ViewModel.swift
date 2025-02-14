import SwiftUI

enum V2MainTabs: Int, CaseIterable {
    case home, passport, scanQr, wallet, profile

    var iconName: String {
        switch self {
        case .home: return Icons.houseSimple
        case .passport: return Icons.passportLine
        case .scanQr: return Icons.qrScan2Line
        case .wallet: return Icons.walletLine
        case .profile: return Icons.accountCircleLine
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.houseSimpleFill
        case .passport: return Icons.passportFill
        case .scanQr: return Icons.qrScan2Line
        case .wallet: return Icons.walletFill
        case .profile: return Icons.accountCircleFill
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
