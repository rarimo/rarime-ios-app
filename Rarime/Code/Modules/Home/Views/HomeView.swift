import Alamofire
import BigInt
import SwiftUI
import Web3

private enum HomeRoute: String, Hashable {
    case notifications
}

struct HomeView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var passportManager: PassportManager

    @StateObject var viewModel = ViewModel()
    @StateObject var findFaceViewModel = FindFaceViewModel()

    @State private var path: [HomeRoute] = []
    @State private var selectedCardId: HomeWidget? = nil
    @State private var isOnboardingPresented = false

    @Namespace private var recoveryNamespace
    @Namespace private var hiddenKeysNamespace
    @Namespace private var likenessNamespace
    @Namespace private var freedomToolNamespace
    @Namespace private var earnNamespace
    @Namespace private var claimTokensNamespace

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .notifications:
                        NotificationsView(onBack: { path.removeLast() })
                            .environment(\.managedObjectContext,
                                         notificationManager.pushNotificationContainer.viewContext)
                            .navigationBarBackButtonHidden()
                    }
                }
                .task { await viewModel.fetchBalance() }
                .task { await findFaceViewModel.loadUser() }
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            switch selectedCardId {
            case .recovery:
                RecoveryMethodView(
                    animation: namespace(for: .recovery),
                    onClose: { selectedCardId = nil }
                )

            case .hiddenKeys:
                FindFaceView(
                    animation: namespace(for: .hiddenKeys),
                    onClose: { selectedCardId = nil },
                    onViewWallet: { mainViewModel.selectedTab = .wallet }
                )
                .environmentObject(findFaceViewModel)

            case .freedomTool:
                PollsView(
                    onClose: { selectedCardId = nil },
                    animation: namespace(for: .freedomTool)
                )

            case .likeness:
                LikenessView(
                    onClose: { selectedCardId = nil },
                    animation: namespace(for: .likeness)
                )

            case .earn:
                InviteFriendsView(
                    balance: viewModel.pointsBalance,
                    onClose: { selectedCardId = nil },
                    animation: namespace(for: .earn)
                )
                .environmentObject(viewModel)

            default:
                mainLayoutContent
            }

            HomeOnboardingView(
                isPresented: isOnboardingPresented,
                onComplete: {
                    isOnboardingPresented = false
                    AppUserDefaults.shared.isHomeOnboardingCompleted = true
                }
            )
            .transition(.identity)
            .zIndex(1)
        }
        .animation(.interpolatingSpring(stiffness: 100, damping: 15),
                   value: selectedCardId)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isOnboardingPresented = !AppUserDefaults.shared.isHomeOnboardingCompleted
            }
        }
    }

    @ViewBuilder
    private var mainLayoutContent: some View {
        MainViewLayout {
            VStack(spacing: 0) {
                header
                HomeWidgetsView(
                    namespaceProvider: namespace,
                    onSelect: { id in selectedCardId = id }
                )
                .environmentObject(viewModel)
                .environmentObject(findFaceViewModel)
            }
            .background(.bgPrimary)
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text("Hi")
                    .h3()
                    .foregroundStyle(.textPrimary)

                if let passport = passportManager.passport {
                    Text(passport.displayedFirstName.capitalized)
                        .additional3()
                        .foregroundStyle(.textSecondary)
                } else {
                    Text("Stranger")
                        .additional3()
                        .foregroundStyle(.textSecondary)
                }
            }

            #if DEVELOPMENT
            Text("Development")
                .caption2()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.warningLighter, in: Capsule())
                .foregroundStyle(Color.warningDark)
            #endif

            Spacer()

            ZStack {
                Button {
                    path.append(.notifications)
                } label: {
                    Image(.notification2Line)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                }

                if notificationManager.unreadNotificationsCounter > 0 {
                    Text(verbatim: "\(notificationManager.unreadNotificationsCounter)")
                        .overline3()
                        .foregroundStyle(.baseWhite)
                        .frame(width: 16, height: 16)
                        .background(Color.errorMain, in: Circle())
                        .overlay { Circle().stroke(Color.invertedLight, lineWidth: 2) }
                        .offset(x: 7, y: -8)
                }
            }
        }
        .zIndex(1)
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 16)
        .background(Color.bgPrimary)
    }

    private func namespace(for key: HomeWidget) -> Namespace.ID {
        switch key {
        case .earn: return earnNamespace
        case .freedomTool: return freedomToolNamespace
        case .hiddenKeys: return hiddenKeysNamespace
        case .recovery: return recoveryNamespace
        case .likeness: return likenessNamespace
        }
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
