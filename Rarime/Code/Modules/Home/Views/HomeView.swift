import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport, reserveTokens, claimRewards, notifications, scanQr
}

struct HomeView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager

    @State private var path: [HomeRoute] = []

    @State private var isRarimeSheetPresented = false
    @State private var isCreateIdentityIntroPresented = false

    @State private var isCongratsShown = false
    @State private var isClaimed = false

    @State private var isBalanceFetching = true
    @State private var pointsBalance: PointsBalanceRaw? = nil
    @State private var cancelables: [Task<Void, Never>] = []

    var canClaimAirdrop: Bool {
        !walletManager.isClaimed
            && passportManager.isEligibleForAirdrop
            && !userManager.isRevoked
            && userManager.registerZkProof != nil
    }

    var canReserveTokens: Bool {
        !(pointsBalance?.isVerified ?? false)
            && !passportManager.isUnsupportedForRewards
            && userManager.registerZkProof != nil
            && userManager.user?.userReferralCode != nil
    }

    var isWalletBalanceDisplayed: Bool {
        passportManager.passport != nil && passportManager.isUnsupportedForRewards
    }

    var displayedBalance: Double {
        isWalletBalanceDisplayed
            ? userManager.balance / Double(Rarimo.rarimoTokenMantis)
            : Double(pointsBalance?.amount ?? 0)
    }

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
                case .reserveTokens:
                    ReserveTokensView(
                        showTerms: true,

                        passport: passportManager.passport,
                        onFinish: { isClaimed in
                            if isClaimed {
                                self.isClaimed = isClaimed
                                self.isCongratsShown = true
                            }

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
                case .notifications:
                    NotificationsView(
                        onBack: {
                            path.removeLast()
                        }
                    )
                    .environment(\.managedObjectContext, notificationManager.pushNotificationContainer.viewContext)
                    .navigationBarBackButtonHidden()
                case .scanQr:
                    ScanQRView(
                        onBack: { path.removeLast() },
                        onScan: processQrCode
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
                VStack(spacing: 0) {
#if DEVELOPMENT
                    Text(verbatim: "Development")
                        .body3()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(.warningLighter)
                        .foregroundStyle(.warningDark)
#endif
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
                        } else {
                            rewardsCard
                        }
                        rarimeCard

                        if canReserveTokens && !isBalanceFetching {
                            reserveTokensCard
                        }
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 12)
                }
            }
            .background(.backgroundPrimary)
        }
        .blur(radius: isCongratsShown ? 12 : 0)
        .overlay(
            CongratsView(
                open: isCongratsShown,
                isClaimed: isClaimed,
                onClose: {
                    isCongratsShown = false
                    fetchBalance()
                }
            )
        )
        .sheet(isPresented: $isCreateIdentityIntroPresented) {
            CreateIdentityIntroView {
                self.isCreateIdentityIntroPresented = false
                path.append(.scanPassport)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    mainViewModel.selectTab(isWalletBalanceDisplayed ? .wallet : .rewards)
                }) {
                    HStack(spacing: 4) {
                        Text(isWalletBalanceDisplayed ? "Balance: RMO" : "Reserved RMO").body3()
                        Image(Icons.caretRight).iconSmall()
                    }
                }
                .foregroundStyle(.textSecondary)
                if isBalanceFetching {
                    ProgressView().frame(height: 40)
                } else {
                    Text(displayedBalance.formatted())
                        .h4()
                        .foregroundStyle(.textPrimary)
                }
            }
            Spacer()
            ZStack {
                Image(Icons.bell)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .onTapGesture { path.append(.notifications) }
                if notificationManager.unreadNotificationsCounter > 0 {
                    Text(verbatim: notificationManager.unreadNotificationsCounter.formatted())
                        .overline3()
                        .foregroundStyle(.baseWhite)
                        .frame(width: 16, height: 16)
                        .background(.errorMain, in: Circle())
                        .offset(x: 7, y: -8)
                }
            }
            Image(Icons.qrCode)
                .iconMedium()
                .foregroundStyle(.textPrimary)
                .onTapGesture { path.append(.scanQr) }
        }
        .padding(.top, 24)
        .padding(.horizontal, 8)
    }

    private var rewardsCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                Image(Images.rewardCoin).square(110)
                VStack(spacing: 8) {
                    Text("Add a Document")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("Create your digital identity")
                        .body2()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                AppButton(text: "Let’s Start", rightIcon: Icons.arrowRight) {
                    self.isCreateIdentityIntroPresented = true
                }
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity)
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

    func processQrCode(_ code: String) {
        guard let qrCodeUrl = URL(string: code) else {
            LoggerUtil.intro.error("Invalid QR code: \(code, privacy: .public)")
            AlertManager.shared.emitError(.unknown("Invalid QR code"))
            return
        }

        externalRequestsManager.handleRarimeUrl(qrCodeUrl)
        path.removeLast()
    }

    func fetchBalance() {
        isBalanceFetching = true

        let cancelable = Task { @MainActor in
            defer {
                self.isBalanceFetching = false
            }

            if userManager.user?.userReferralCode == nil {
                return
            }

            do {
                if isWalletBalanceDisplayed {
                    let balance = try await userManager.fetchBalanse()
                    userManager.balance = Double(balance) ?? 0
                    return
                }

                guard let user = userManager.user else { throw "failed to get user" }

                let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)

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
        .environmentObject(NotificationManager())
        .environmentObject(ExternalRequestsManager())
}
