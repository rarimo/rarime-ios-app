import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport, scanQR
}

struct HomeView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [HomeRoute] = []

    @State private var isBetaLaunchSheetPresented = false
    @State private var isAirdropSheetPresented = false
    @State private var isPassportSheetPresented = false
    @State private var isRarimeSheetPresented = false

    @State private var isCongratsShown = false
    @State private var isClaimed = false
    
    @State private var isBalanceFetching = false
    @State private var cancelables: [Task<(), Never>] = []

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .scanPassport:
                    ScanPassportView(
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
                    try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
                }
            ) { _ in
                VStack(spacing: 24) {
                    HStack {
                        Text("Beta launch").body3()
                        Image(Icons.info)
                            .iconSmall()
                            .onTapGesture { isBetaLaunchSheetPresented = true }
                            .dynamicSheet(isPresented: $isBetaLaunchSheetPresented, fullScreen: true) {
                                BetaLaunchView(onClose: { isBetaLaunchSheetPresented = false })
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.warningDark)
                    .padding(.vertical, 4)
                    .background(.warningLighter)
                    VStack(alignment: .leading, spacing: 32) {
                        header
                        VStack(spacing: 24) {
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
                                    )
                                )
                                rarimeCard
                            } else {
                                airdropCard
                                otherPassportsCard
                            }
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
        .overlay(CongratsView(open: $isCongratsShown, isClaimed: isClaimed))
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
                Button(action: { path.append(.scanQR) }) {
                    Image(Icons.qrCode)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                }
            }

            HStack {
                if isBalanceFetching {
                    ProgressView()
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
                Text("🇺🇦")
                    .h4()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary)
                    .clipShape(Circle())
                VStack(spacing: 8) {
                    Text("Programable Airdrop")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("Beta launch is focused on distributing tokens to Ukrainian identity holders")
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
            title: "Other passport holders",
            description: "Join a waitlist"
        )
        .onTapGesture { isPassportSheetPresented = true }
        .dynamicSheet(isPresented: $isPassportSheetPresented, fullScreen: true) {
            PassportIntroView(onStart: {
                isPassportSheetPresented = false
                path.append(.scanPassport)
            })
        }
    }

    private var rarimeCard: some View {
        ActionCard(
            title: "RARIME",
            description: "Learn more about RariMe App"
        )
        .onTapGesture { isRarimeSheetPresented = true }
        .dynamicSheet(isPresented: $isRarimeSheetPresented, fullScreen: true) {
            RarimeInfoView(onClose: { isRarimeSheetPresented = false })
        }
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
                LoggerUtil.intro.error("failed to fetch balance: \(error)")
            }
        }
        
        self.cancelables.append(cancelable)
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
