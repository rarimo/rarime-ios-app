import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport, scanQR, claimRewards
}

struct HomeView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [HomeRoute] = []

    @State private var isAirdropSheetPresented = false
    @State private var isPassportSheetPresented = false
    @State private var isRarimeSheetPresented = false

    @State private var isAirdropFlow = false
    @State private var isCongratsShown = false
    @State private var isClaimed = false

    @State private var isBalanceFetching = true
    @State private var cancelables: [Task<Void, Never>] = []

    var canClaimAirdrop: Bool {
        !walletManager.isClaimed && passportManager.isEligibleForReward && userManager.registerZkProof != nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .scanPassport:
                    ScanPassportView(
                        showTerms: !isAirdropFlow,
                        onComplete: { passport, isClaimed in
                            passportManager.setPassport(passport)
                            isCongratsShown = true
                            self.isClaimed = isClaimed
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .scanQR:
                    ScanQRView(
                        onBack: { path.removeLast() },
                        onScan: { _ in path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .claimRewards:
                    ClaimTokensView(
                        showTerms: true,
                        passport: passportManager.passport,
                        onFinish: {
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
                    Text("Beta launch")
                        .body3()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.warningDark)
                        .padding(.vertical, 4)
                        .background(.warningLighter)
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        if let passport = passportManager.passport {
                            PassportCard(
                                passport: passport,
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
                            if canClaimAirdrop {
                                claimCard
                            }
                            rarimeCard
                        } else {
                            airdropCard
                            otherPassportsCard
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.top, 1)
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
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { mainViewModel.selectTab(.wallet) }) {
                    HStack(spacing: 4) {
                        Text("Balance: RMO").body3()
                        Image(Icons.caretRight).iconSmall()
                    }
                }
                .foregroundStyle(.textSecondary)
                Spacer()
//                TODO: uncomment when QR proofs are ready
//                Button(action: { path.append(.scanQR) }) {
//                    Image(Icons.qrCode)
//                        .iconMedium()
//                        .foregroundStyle(.textPrimary)
//                }
            }

            HStack {
                if isBalanceFetching {
                    ProgressView().frame(height: 40)
                } else {
                    Text((userManager.balance / Double(Rarimo.rarimoTokenMantis)).formatted())
                        .h4()
                        .foregroundStyle(.textPrimary)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }

    private var airdropCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                Text(String("🇺🇦"))
                    .h4()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary)
                    .clipShape(Circle())
                VStack(spacing: 8) {
                    Text("Programmable Airdrop")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("The beta launch is focused on distributing tokens to Ukrainian citizens")
                        .body2()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                AppButton(text: "Let’s Start", rightIcon: Icons.arrowRight) {
                    isAirdropSheetPresented = true
                }
                .controlSize(.large)
                .dynamicSheet(isPresented: $isAirdropSheetPresented, fullScreen: true) {
                    AirdropIntroView(
                        onStart: {
                            isAirdropSheetPresented = false
                            isAirdropFlow = true
                            path.append(.scanPassport)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var otherPassportsCard: some View {
        ActionCard(
            title: String(localized: "Other passport holders"),
            description: String(localized: "Join a waitlist")
        )
        .onTapGesture { isPassportSheetPresented = true }
        .dynamicSheet(isPresented: $isPassportSheetPresented, fullScreen: true) {
            PassportIntroView(onStart: {
                isPassportSheetPresented = false
                isAirdropFlow = false
                path.append(.scanPassport)
            })
        }
    }

    private var rarimeCard: some View {
        ActionCard(
            title: String(localized: "RARIME"),
            description: String(localized: "Learn more about RariMe App"),
            icon: { Image(Icons.info).square(24).padding(8) }
        )
        .onTapGesture { isRarimeSheetPresented = true }
        .dynamicSheet(isPresented: $isRarimeSheetPresented, fullScreen: true) {
            RarimeInfoView(onClose: { isRarimeSheetPresented = false })
        }
    }

    private var claimCard: some View {
        ActionCard(
            title: String(localized: "Claim rewards"),
            description: String(localized: "You’ve earned \(RARIMO_AIRDROP_REWARD) RMO"),
            icon: { Image(Images.rewardCoin).square(40) }
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
                let balance = try await userManager.fetchBalanse()

                self.userManager.balance = Double(balance) ?? 0
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to fetch balance: \(error.localizedDescription)")
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
}
