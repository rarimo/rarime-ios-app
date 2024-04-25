import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport, scanQR
}

struct HomeView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var mainViewModel: MainView.ViewModel

    @State private var path: [HomeRoute] = []

    @State private var isBetaLaunchSheetPresented = false
    @State private var isAirdropSheetPresented = false
    @State private var isPassportSheetPresented = false
    @State private var isRarimeSheetPresented = false

    @State private var isCongratsShown = false
    @State private var isClaimed = false

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
    }

    private var content: some View {
        MainViewLayout {
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
                                ),
                                onDelete: { passportManager.removePassport() }
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
                Text(walletManager.balance.formatted())
                    .h4()
                    .foregroundStyle(.textPrimary)
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
}

#Preview {
    HomeView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
}
