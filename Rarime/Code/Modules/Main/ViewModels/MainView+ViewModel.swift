import SwiftUI

enum MainTabs: Int, CaseIterable {
    case home, profile

    var iconName: String {
        switch self {
        case .home: return Icons.houseSimple
        case .profile: return Icons.user
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.houseSimpleFill
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
