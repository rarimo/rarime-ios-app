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

    @StateObject var viewModel = ViewModel()

    @State private var path: V2HomeRoute? = nil
    @State private var isCopied = false

    @Namespace var identityAnimation
    @Namespace var inviteFriendsAnimation
    @Namespace var claimTokensAnimation
    @Namespace var walletAnimation
    @Namespace var votingAnimation

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
                IdentityIntroView(
                    onClose: { path = nil },
                    // TODO: change after design impl
                    onStart: { path = nil },
                    animation: identityAnimation
                )
            case .inviteFriends:
                V2InviteFriendsView(
                    // TODO: change after design impl for nonscanned passports
                    balance: PointsBalanceRaw(
                        amount: 12,
                        isDisabled: false,
                        createdAt: Int(Date().timeIntervalSince1970),
                        updatedAt: Int(Date().timeIntervalSince1970),
                        rank: 12,
                        referralCodes: [
                            ReferalCode(id: "title 1", status: .active),
                            ReferalCode(id: "title 2", status: .awaiting),
                            ReferalCode(id: "title 3", status: .banned),
                            ReferalCode(id: "title 4", status: .consumed),
                            ReferalCode(id: "title 5", status: .limited),
                            ReferalCode(id: "title 6", status: .rewarded)
                        ],
                        level: 2,
                        isVerified: true
                    ),
                    onClose: { path = nil },
                    animation: inviteFriendsAnimation
                )
            case .claimTokens:
                V2ClaimTokensView(
                    onClose: { path = nil },
                    // TODO: change after design impl
                    onClaim: { path = nil },
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
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Text("Hi")
                    .subtitle4()
                    .foregroundStyle(.textSecondary)
                Text("User")
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
                                HStack(spacing: 16) {
                                    Text("14925-1592")
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
                            },
                            animation: inviteFriendsAnimation
                        )
                        .onTapGesture {
                            path = .inviteFriends
                        }
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
                            subtitle: "10 RMO",
                            bottomAdditionalContent: { EmptyView() },
                            animation: claimTokensAnimation
                        )
                        .onTapGesture {
                            path = .claimTokens
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
