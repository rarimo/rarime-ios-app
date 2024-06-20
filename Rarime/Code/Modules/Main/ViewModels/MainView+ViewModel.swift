import SwiftUI

enum MainTabs: Int, CaseIterable {
    case home, wallet, rewards, profile

    var iconName: String {
        switch self {
        case .home: return Icons.houseSimple
        case .wallet: return Icons.wallet
        case .rewards: return Icons.airdrop
        case .profile: return Icons.user
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.houseSimpleFill
        case .wallet: return Icons.walletFilled
        case .rewards: return Icons.airdrop
        case .profile: return Icons.user
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var selectedTab: MainTabs = .home
        
        @Published var isRewardsSheetPresented = false

        func selectTab(_ tab: MainTabs) {
            selectedTab = tab
        }
    }
}
