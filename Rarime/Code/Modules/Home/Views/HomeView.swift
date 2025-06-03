import Alamofire
import SwiftUI

enum HomeRoute: String, Hashable {
    case notifications
}

enum HomeCardId: Hashable {
    case recovery
    case findFace
    case likeness
    case freedomTool
    case inviteFriends
    case claimTokens
}

struct HomeAnimations {
    @Namespace var recovery
    @Namespace var findFace
    @Namespace var likeness
    @Namespace var freedomTool
    @Namespace var inviteFriends
    @Namespace var claimTokens

    func id(for key: HomeCardId) -> Namespace.ID {
        switch key {
        case .recovery: recovery
        case .findFace: findFace
        case .likeness: likeness
        case .freedomTool: freedomTool
        case .inviteFriends: inviteFriends
        case .claimTokens: claimTokens
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var passportManager: PassportManager

    @StateObject var viewModel = ViewModel()
    @StateObject var findFaceViewModel = FindFaceViewModel()

    @State private var path: [HomeRoute] = []
    @State private var selectedCardId: HomeCardId? = nil
    @State private var animations = HomeAnimations()

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .notifications:
                    NotificationsView(onBack: { path.removeLast() })
                        .environment(\.managedObjectContext, notificationManager.pushNotificationContainer.viewContext)
                        .navigationBarBackButtonHidden()
                }
            }
            .task { await viewModel.fetchBalance() }
            .task { await findFaceViewModel.loadUser() }
        }
    }

    private var content: some View {
        ZStack {
            switch selectedCardId {
            case .recovery:
                RecoveryMethodView(
                    animation: animations.id(for: .recovery),
                    onClose: { selectedCardId = nil }
                )
            case .findFace:
                FindFaceView(
                    animation: animations.id(for: .findFace),
                    onClose: { selectedCardId = nil },
                    onViewWallet: {
                        mainViewModel.selectedTab = .wallet
                    }
                )
                .environmentObject(findFaceViewModel)
            case .freedomTool:
                PollsView(
                    onClose: { selectedCardId = nil },
                    animation: animations.id(for: .freedomTool)
                )
            case .likeness:
                LikenessView(
                    onClose: { selectedCardId = nil },
                    animation: animations.id(for: .likeness)
                )
            case .inviteFriends:
                InviteFriendsView(
                    balance: viewModel.pointsBalance,
                    onClose: { selectedCardId = nil },
                    animation: animations.id(for: .inviteFriends)
                )
            case .claimTokens:
                ClaimTokensView(
                    onClose: { selectedCardId = nil },
                    pointsBalance: viewModel.pointsBalance,
                    animation: animations.id(for: .claimTokens)
                )
            default:
                mainLayoutContent
            }
        }
        .animation(.interpolatingSpring(stiffness: 100, damping: 15), value: selectedCardId)
    }

    private var mainLayoutContent: some View {
        MainViewLayout {
            VStack(spacing: 0) {
                header
                HomeWidgetsView(
                    animations: animations,
                    onSelect: { id in selectedCardId = id }
                )
                .environmentObject(viewModel)
                .environmentObject(findFaceViewModel)
            }
            .background(.bgPrimary)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text("Hi")
                    .h3()
                    .foregroundStyle(.textPrimary)
                Group {
                    if passportManager.passport != nil {
                        Text(passportManager.passport?.displayedFirstName.capitalized ?? "")
                    } else {
                        Text("Stranger")
                    }
                }
                .additional3()
                .foregroundStyle(.textSecondary)
            }
            #if DEVELOPMENT
                Text(verbatim: "Development")
                    .caption2()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.warningLighter, in: Capsule())
                    .foregroundStyle(.warningDark)
            #endif
            Spacer()
            ZStack {
                Button(action: { path.append(.notifications) }) {
                    Image(.notification2Line)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                }
                if notificationManager.unreadNotificationsCounter > 0 {
                    Text(verbatim: notificationManager.unreadNotificationsCounter.formatted())
                        .overline3()
                        .foregroundStyle(.baseWhite)
                        .frame(width: 16, height: 16)
                        .background(.errorMain, in: Circle())
                        .overlay { Circle().stroke(.invertedLight, lineWidth: 2) }
                        .offset(x: 7, y: -8)
                }
            }
        }
        .zIndex(1)
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 16)
        .background(.bgPrimary)
    }
}

#Preview {
    HomeView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(NotificationManager())
        .environmentObject(LikenessManager())
        .environmentObject(ConfigManager())
        .environmentObject(PollsViewModel())
}
