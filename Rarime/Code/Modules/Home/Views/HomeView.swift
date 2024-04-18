import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport
}

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    @EnvironmentObject var mainViewModel: MainView.ViewModel
    @EnvironmentObject var walletViewModel: WalletViewModel

    @State private var path: [HomeRoute] = []
    @StateObject private var viewModel = ViewModel()

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
                            viewModel.setPassport(passport)
                            isCongratsShown = true
                            self.isClaimed = isClaimed
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }

    private var content: some View {
        VStack(spacing: 24) {
            Text("Beta launch")
                .body3()
                .frame(maxWidth: .infinity)
                .foregroundStyle(.warningDark)
                .padding(.vertical, 4)
                .background(.warningLighter)
            VStack(alignment: .leading, spacing: 32) {
                header
                VStack(spacing: 24) {
                    if let passport = viewModel.passport {
                        PassportCard(
                            look: viewModel.passportCardLook,
                            passport: passport,
                            onLookChange: { look in viewModel.setPassportCardLook(look) },
                            onDelete: { viewModel.removePassport() }
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
                Button(action: {}) {
                    Image(Icons.qrCode).iconMedium()
                }
            }

            HStack {
                Text(walletViewModel.balance.formatted()).h4().foregroundStyle(.textPrimary)
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
                    .environmentObject(appViewModel)
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
        .environmentObject(AppView.ViewModel())
        .environmentObject(MainView.ViewModel())
        .environmentObject(WalletViewModel())
}
