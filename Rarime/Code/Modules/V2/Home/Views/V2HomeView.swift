import SwiftUI

enum V2HomeRoute: Hashable {
    case notifications, identity, inviteFriends, claimTokens, wallet
}

struct V2HomeView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var mainViewModel: V2MainView.ViewModel
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject private var configManager: ConfigManager

    @StateObject var viewModel = ViewModel()

    @State private var path: V2HomeRoute? = nil
    @State private var isCopied = false

    @State private var isBalanceFetching = true
    @State private var pointsBalance: PointsBalanceRaw? = nil
    @State private var cancelables: [Task<Void, Never>] = []

    @Namespace var identityAnimation
    @Namespace var inviteFriendsAnimation
    @Namespace var claimTokensAnimation
    @Namespace var walletAnimation
    @Namespace var votingAnimation

    private var activeReferralCode: String? {
        pointsBalance?.referralCodes?
            .filter { $0.status == .active }
            .first?.id
    }

    var body: some View {
        ZStack {
            switch path {
            case .notifications:
                NotificationsView(
                    onBack: { path = nil }
                )
                .environment(
                    \.managedObjectContext,
                    notificationManager.pushNotificationContainer.viewContext
                )
            case .identity:
                IdentityOnboardingView(
                    onClose: { path = nil },
                    onStart: {
                        path = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            mainViewModel.selectedTab = .identity
                        }
                    },
                    animation: identityAnimation
                )
            case .inviteFriends:
                V2InviteFriendsView(
                    balance: pointsBalance,
                    onClose: { path = nil },
                    animation: inviteFriendsAnimation
                )
            case .claimTokens:
                V2ClaimTokensView(
                    onClose: { path = nil },
                    animation: claimTokensAnimation
                )
            case .wallet:
                WalletWaitlistView(
                    onClose: { path = nil },
                    // TODO: change after design impl
                    onJoin: { path = nil },
                    animation: walletAnimation
                )
            default: content
            }
        }
        .animation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15), value: path)
        .onAppear(perform: fetchBalance)
        .onDisappear(perform: cleanup)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Text("Hi")
                    .subtitle4()
                    .foregroundStyle(.textSecondary)
                Group {
                    if passportManager.passport != nil {
                        Text(passportManager.passport?.displayedFirstName ?? "")
                    } else {
                        Text("User")
                    }
                }
                .subtitle4()
                .foregroundStyle(.textPrimary)
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
                AppIconButton(icon: Icons.notification2Line, action: { path = .notifications })
                if notificationManager.unreadNotificationsCounter > 0 {
                    Text(verbatim: notificationManager.unreadNotificationsCounter.formatted())
                        .overline3()
                        .foregroundStyle(.baseWhite)
                        .frame(width: 16, height: 16)
                        .background(.errorMain, in: Circle())
                        .offset(x: 7, y: -8)
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
        .background(.bgBlur)
        .zIndex(1)
    }

    private var content: some View {
        V2MainViewLayout {
            VStack(spacing: 0) {
                header
                ZStack(alignment: .trailing) {
                    SnapCarouselView(index: $viewModel.currentIndex) {
                        HomeCardView(
                            backgroundGradient: Gradients.gradientFirst,
                            topIcon: Icons.rarime,
                            bottomIcon: Icons.arrowRightUpLine,
                            imageContent: {
                                Image(Images.handWithPhone)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.88)
                                    .offset(x: 32)
                                    .padding(.top, 12)
                            },
                            title: "Your Device",
                            subtitle: "Your Identity",
                            bottomAdditionalContent: {
                                Text("* Nothing leaves this device")
                                    .body4()
                                    .foregroundStyle(.baseBlack.opacity(0.6))
                                    .padding(.top, 24)
                            },
                            animation: identityAnimation
                        )
                        .onTapGesture {
                            path = .identity
                        }
                        HomeCardView(
                            backgroundGradient: Gradients.gradientFourth,
                            topIcon: Icons.rarime,
                            bottomIcon: Icons.arrowRightUpLine,
                            imageContent: {
                                Image(Images.seedPhraseShred)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.top, 96)
                            },
                            title: "An Unforgettable",
                            subtitle: "Wallet",
                            bottomAdditionalContent: { EmptyView() },
                            animation: walletAnimation
                        )
                        .onTapGesture {
                            path = .wallet
                        }
                        if !isBalanceFetching && pointsBalance != nil {
                            HomeCardView(
                                backgroundGradient: Gradients.gradientSecond,
                                topIcon: Icons.rarime,
                                bottomIcon: Icons.arrowRightUpLine,
                                imageContent: {
                                    ZStack(alignment: .bottomTrailing) {
                                        Image(Images.peopleEmojis)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.top, 84)

                                        Image(Icons.getTokensArrow)
                                            .foregroundStyle(.informationalDark)
                                            .offset(x: -44, y: 88)
                                            .matchedGeometryEffect(
                                                id: AnimationNamespaceIds.additionalImage,
                                                in: inviteFriendsAnimation
                                            )
                                    }
                                },
                                title: "Invite",
                                subtitle: "Others",
                                bottomAdditionalContent: {
                                    if let code = activeReferralCode {
                                        HStack(spacing: 16) {
                                            Text(code)
                                                .subtitle4()
                                                .foregroundStyle(.baseBlack)
                                            VerticalDivider()
                                            Image(isCopied ? Icons.checkLine : Icons.fileCopyLine)
                                                .iconMedium()
                                                .foregroundStyle(.baseBlack.opacity(0.5))
                                        }
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(.baseWhite)
                                        .cornerRadius(8)
                                        .frame(maxWidth: 230, alignment: .leading)
                                        .padding(.top, 24)
                                        .onTapGesture {
                                            if isCopied { return }

                                            isCopied = true
                                            FeedbackGenerator.shared.impact(.medium)

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                isCopied = false
                                            }
                                        }
                                    }
                                },
                                animation: inviteFriendsAnimation
                            )
                            .onTapGesture {
                                path = .inviteFriends
                            }
                        }
                        if (pointsBalance?.amount ?? 0) > 0 {
                            HomeCardView(
                                backgroundGradient: Gradients.gradientThird,
                                topIcon: Icons.rarimo,
                                bottomIcon: Icons.arrowRightUpLine,
                                imageContent: {
                                    Image(Images.rarimoTokens)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.top, 100)
                                },
                                title: "Claim",
                                subtitle: "\(pointsBalance!.amount.formatted()) RMO",
                                bottomAdditionalContent: { EmptyView() },
                                animation: claimTokensAnimation
                            )
                            .onTapGesture {
                                path = .claimTokens
                            }
                        }
                        HomeCardView(
                            backgroundGradient: Gradients.gradientFifth,
                            topIcon: Icons.freedomtool,
                            bottomIcon: Icons.arrowRightUpLine,
                            imageContent: {
                                Image(Images.dotCountry)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.top, 8)
                            },
                            title: "Freedomtool",
                            subtitle: "Voting",
                            bottomAdditionalContent: { EmptyView() },
                            animation: votingAnimation
                        )
                    }
                    .padding(.horizontal, 22)
                    V2StepIndicator(steps: 5, currentStep: viewModel.currentIndex)
                        .padding(.trailing, 8)
                }
            }
            .background(.bgPrimary)
        }
    }

    func fetchBalance() {
        isBalanceFetching = true

        let cancelable = Task { @MainActor in
            defer {
                self.isBalanceFetching = false
            }

            if userManager.user?.userReferralCode == nil {
                await verifyReferralCode()
                return
            }

            do {
                guard let user = userManager.user else { throw "failed to get user" }
                let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)

                let pointsBalance = try await userManager.fetchPointsBalance(accessJwt)
                self.pointsBalance = pointsBalance
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.common.error("failed to fetch balance: \(error.localizedDescription, privacy: .public)")
            }
        }

        cancelables.append(cancelable)
    }

    private func verifyReferralCode() async {
        var referralCode = configManager.api.defaultReferralCode
        if let deferredReferralCode = userManager.user?.deferredReferralCode, !deferredReferralCode.isEmpty {
            referralCode = deferredReferralCode
        }

        await attemptToCreateBalance(with: referralCode, fallback: configManager.api.defaultReferralCode)
    }

    private func attemptToCreateBalance(with referralCode: String, fallback: String) async {
        do {
            try await createBalance(referralCode)
        } catch {
            LoggerUtil.common.error("Failed to verify referral code: \(error.localizedDescription, privacy: .public)")
            if referralCode != fallback {
                await attemptToCreateBalance(with: fallback, fallback: fallback)
            }
        }
    }

    private func createBalance(_ code: String) async throws {
        guard let user = userManager.user else { throw "user is not initalized" }
        let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)

        let pointsSvc = Points(ConfigManager.shared.api.pointsServiceURL)
        let result = try await pointsSvc.createPointsBalance(
            accessJwt,
            code
        )

        userManager.user?.userReferralCode = code
        LoggerUtil.common.info("User verified code: \(code, privacy: .public)")

        pointsBalance = PointsBalanceRaw(
            id: result.data.id,
            amount: result.data.attributes.amount,
            isDisabled: result.data.attributes.isDisabled,
            createdAt: result.data.attributes.createdAt,
            updatedAt: result.data.attributes.updatedAt,
            rank: result.data.attributes.rank,
            referralCodes: result.data.attributes.referralCodes,
            level: result.data.attributes.level,
            isVerified: result.data.attributes.isVerified
        )
    }

    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
}

#Preview {
    V2HomeView()
        .environmentObject(V2MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(NotificationManager())
        .environmentObject(ExternalRequestsManager())
}
