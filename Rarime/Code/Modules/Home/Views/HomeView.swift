import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport, zkp
}

struct HomeView: View {
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [HomeRoute] = []

    @State private var isRarimeSheetPresented = false

    @State private var isCongratsShown = false

    @State private var pointsBalance: PointsBalanceRaw? = nil
    @State private var cancelables: [Task<Void, Never>] = []

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .scanPassport:
                    ScanPassportView(
                        onComplete: { passport in
                            userManager.user?.status = .passportScanned
                            
                            passportManager.setPassport(passport)
                            isCongratsShown = true
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .zkp:
                    ZkpView() {
                        _ = path.removeLast()
                    }
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }

    private var content: some View {
        MainViewLayout {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack {
                        if let passport = passportManager.passport {
                            PassportCard(
                                onZkp: {
                                    path.append(.zkp)
                                },
                                passport: passport,
                                isWaitlist: userManager.registerZkProof == nil,
                                look: Binding(
                                    get: { passportManager.passportCardLook },
                                    set: { passportManager.setPassportCardLook($0) }
                                ),
                                isIncognito: Binding(
                                    get: { passportManager.isIncognitoMode },
                                    set: { passportManager.setIncognitoMode($0) }
                                ),
                                identifiers: Binding(
                                    get: { passportManager.passportIdentifiers },
                                    set: { passportManager.setPassportIdentifiers($0) }
                                )
                            )
                        } else {
                            rewardsCard
                        }
                    }
                    .padding(.top, 50)
                    Spacer()
                }
                .padding(.horizontal, 12)
            }
            .background(.backgroundPrimary)
        }
    }

    private var rewardsCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                Image(Images.rewardCoin)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.white)
                    .frame(width: 110, height: 110)
                VStack(spacing: 8) {
                    Text("Add a Document")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("Scan your document to retrive data for ZKPs")
                        .body2()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                AppButton(text: "Scan", rightIcon: Icons.arrowRight) {
                    path.append(.scanPassport)
                }
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
}
