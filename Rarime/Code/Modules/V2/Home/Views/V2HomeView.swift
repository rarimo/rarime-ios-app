import SwiftUI

enum V2HomeRoute: Hashable {
    case notifications, identity, inviteFriends, claimTokens, wallet, polls
}

struct V2HomeView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var mainViewModel: V2MainView.ViewModel
    @EnvironmentObject private var pollsViewModel: PollsViewModel
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject private var configManager: ConfigManager

    @StateObject var viewModel = HomeViewModel()

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
    
    private var userPointsBalance: Int {
        pointsBalance?.amount ?? 0
    }
    
    private var homeCards: [HomeCarouselCard] {
        [
            HomeCarouselCard(action: { path = .identity }) {
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
            },
            HomeCarouselCard(
                isShouldDisplay: !isBalanceFetching && pointsBalance != nil,
                action: { path = .inviteFriends }
            ) {
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
                                VerticalDivider(color: .bgComponentBasePrimary)
                                Image(isCopied ? Icons.checkLine : Icons.fileCopyLine)
                                    .iconMedium()
                                    .foregroundStyle(.baseBlack.opacity(0.5))
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.baseWhite)
                            .cornerRadius(8)
                            .frame(maxWidth: 280, alignment: .leading)
                            .padding(.top, 24)
                            .onTapGesture {
                                if isCopied { return }

                                isCopied = true
                                FeedbackGenerator.shared.impact(.medium)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.easeInOut) {
                                        isCopied = false
                                    }
                                }
                            }
                        }
                    },
                    animation: inviteFriendsAnimation
                )
            },
            HomeCarouselCard(
                isShouldDisplay: userPointsBalance > 0,
                action: { path = .claimTokens }
            ) {
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
                    subtitle: "\(userPointsBalance.formatted()) RMO",
                    animation: claimTokensAnimation
                )
            },
            HomeCarouselCard(action: { path = .wallet }) {
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
                    animation: walletAnimation
                )
            },
            HomeCarouselCard(action: { path = .polls }) {
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
                    animation: votingAnimation
                )
            }
        ]
    }

    var body: some View {
        ZStack {
            if path == .notifications {
                NotificationsView(onBack: { path = nil })
                    .environment(\.managedObjectContext, notificationManager.pushNotificationContainer.viewContext)
                    .transition(.backslide)
            } else {
                switch path {
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
                        onJoin: { path = nil },
                        animation: walletAnimation
                    )
                case .polls:
                    PollsView(
                        onClose: { path = nil },
                        animation: votingAnimation
                    )
                default:
                    content
                }
            }
        }
        .animation(
            path == .notifications
                ? .easeInOut
                : .interpolatingSpring(mass: 1, stiffness: 100, damping: 15),
            value: path
        )
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
        .zIndex(1)
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 16)
        .background {
            ZStack {
                Color.bgBlur
                TransparentBlurView(removeAllFilters: false)
            }
            .ignoresSafeArea(.container, edges: .top)
        }
    }

    private var content: some View {
        V2MainViewLayout {
            VStack(spacing: 0) {
                header
                ZStack(alignment: .trailing) {
                    SnapCarouselView(
                        index: $viewModel.currentCardIndex,
                        cards: homeCards.filter { $0.isShouldDisplay }
                    )
                    .padding(.horizontal, 22)
                    V2StepIndicator(
                        steps: homeCards.filter(\.isShouldDisplay).count,
                        currentStep: viewModel.currentCardIndex
                    )
                    .padding(.trailing, 8)
                }
            }
            .background(.bgPrimary)
        }
    }

    private func fetchBalance() {
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

    private func cleanup() {
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
