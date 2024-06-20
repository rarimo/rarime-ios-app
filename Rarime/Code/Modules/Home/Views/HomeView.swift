import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport, reserveTokens, claimRewards
}

struct HomeView: View {
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [HomeRoute] = []

    @State private var isUkrainianSheetPresented = false
    @State private var isRarimeSheetPresented = false

    @State private var isAirdropFlow = false
    @State private var isCongratsShown = false
    @State private var isClaimed = false

    @State private var isBalanceFetching = true
    @State private var pointsBalance: PointsBalanceRaw? = nil
    @State private var cancelables: [Task<Void, Never>] = []

    var canClaimAirdrop: Bool {
        !walletManager.isClaimed
            && passportManager.isEligibleForReward
            && !userManager.isRevoked
            && userManager.registerZkProof != nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .scanPassport:
                    ScanPassportView(
                        isAirdropFlow: isAirdropFlow,
                        onComplete: { passport, isClaimed in
                            userManager.user?.status = .passportScanned

                            passportManager.setPassport(passport)
                            isCongratsShown = true
                            self.isClaimed = isClaimed
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .reserveTokens:
                    ReserveTokensView(
                        showTerms: true,
                        
                        passport: passportManager.passport,
                        onFinish: { _ in
                            isClaimed = true
                            isCongratsShown = true
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .claimRewards:
                    ClaimTokensView(
                        showTerms: true,
                        passport: passportManager.passport,
                        onFinish: { _ in
                            isClaimed = true
                            isCongratsShown = true
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                }
            }
        }
        .onAppear(perform: fetchBalance)
        .onDisappear(perform: cleanup)
    }

    private var content: some View {
        MainViewLayout {
            RefreshableScrollView(
                onRefresh: {
                    fetchBalance()
                    try await Task.sleep(nanoseconds: 1_200_000_000)
                }
            ) { _ in
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        if let passport = passportManager.passport {
                            PassportCard(
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
                            if !userManager.isPassportTokensReserved {
                                reserveTokensCard
                            }
                            // TODO: uncomment it in the future release
//                            if canClaimAirdrop {
//                                claimCard
//                            }
                        } else {
                            rewardsCard
                            // TODO: uncomment it in the future release
//                            ukrainianCitizensCard
                        }
                        rarimeCard
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.top, 32)
            .background(.backgroundPrimary)
        }
        .blur(radius: isCongratsShown ? 12 : 0)
        .overlay(
            CongratsView(
                open: isCongratsShown,
                isClaimed: isClaimed,
                isAirdropFlow: isAirdropFlow,
                onClose: {
                    isCongratsShown = false
                    fetchBalance()
                }
            )
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { mainViewModel.selectTab(.rewards) }) {
                HStack(spacing: 4) {
                    Text("Reserved RMO").body3()
                    Image(Icons.caretRight).iconSmall()
                }
            }
            .foregroundStyle(.textSecondary)
            if isBalanceFetching {
                ProgressView().frame(height: 40)
            } else {
                Text("\(self.pointsBalance?.amount ?? 0)")
                    .h4()
                    .foregroundStyle(.textPrimary)
            }
        }
        .padding(.horizontal, 8)
    }

    private var rewardsCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                Image(Images.rewardCoin).square(110)
                VStack(spacing: 8) {
                    Text("Join Rewards Program")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("Check your eligibility")
                        .body2()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                AppButton(text: "Let’s Start", rightIcon: Icons.arrowRight) {
                    mainViewModel.isRewardsSheetPresented = true
                }
                .controlSize(.large)
                .dynamicSheet(isPresented: $mainViewModel.isRewardsSheetPresented, fullScreen: true) {
                    RewardsIntroView(
                        onStart: {
                            mainViewModel.isRewardsSheetPresented = false
                            isAirdropFlow = false
                            path.append(.scanPassport)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var ukrainianCitizensCard: some View {
        ActionCard(
            title: String(localized: "Ukrainian citizens"),
            description: String(localized: "Programmable rewards"),
            icon: { Text(Country.ukraine.flag).frame(width: 40, height: 40) }
        )
        .onTapGesture { isUkrainianSheetPresented = true }
        .dynamicSheet(isPresented: $isUkrainianSheetPresented, fullScreen: true) {
            UkrainianIntroView(onStart: {
                isUkrainianSheetPresented = false
                isAirdropFlow = true
                path.append(.scanPassport)
            })
        }
    }

    private var rarimeCard: some View {
        ActionCard(
            title: String(localized: "RARIME"),
            description: String(localized: "Learn more about the App"),
            transparent: true,
            icon: { Image(Icons.info).square(24).padding(8) }
        )
        .onTapGesture { isRarimeSheetPresented = true }
        .dynamicSheet(isPresented: $isRarimeSheetPresented, fullScreen: true) {
            RarimeInfoView(onClose: { isRarimeSheetPresented = false })
        }
    }

    private var reserveTokensCard: some View {
        ActionCard(
            title: String(localized: "Reserve tokens"),
            description: String(localized: "You’re entitled for \(PASSPORT_RESERVE_TOKENS.formatted()) RMO"),
            icon: { Image(Images.rewardCoin).square(40) }
        )
        .onTapGesture { path.append(.reserveTokens) }
    }

    private var claimCard: some View {
        ActionCard(
            title: String(localized: "Claim"),
            description: String(localized: "You’ve earned \(RARIMO_AIRDROP_REWARD) RMO"),
            icon: { Text(Country.ukraine.flag).frame(width: 40, height: 40) }
        )
        .onTapGesture { path.append(.claimRewards) }
    }

    func fetchBalance() {
        isBalanceFetching = true

        let cancelable = Task { @MainActor in
            defer {
                self.isBalanceFetching = false
            }

            do {
                guard let user = userManager.user else { throw "failed to get user" }
                
                if decentralizedAuthManager.accessJwt == nil {
                    try await decentralizedAuthManager.initializeJWT(user.secretKey)
                }
                
                try await decentralizedAuthManager.refreshIfNeeded()
                
                guard let accessJwt = decentralizedAuthManager.accessJwt else { throw "accessJwt is nil" }
                
                let pointsBalance = try await userManager.fetchPointsBalance(accessJwt)
                
                self.pointsBalance = pointsBalance
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to fetch balance: \(error.localizedDescription, privacy: .public)")
            }
        }

        cancelables.append(cancelable)
    }

    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
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
