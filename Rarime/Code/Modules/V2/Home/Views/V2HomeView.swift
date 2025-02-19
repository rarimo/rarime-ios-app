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
            switch(path) {
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
        HStack {
            HStack(spacing: 8) {
                Text("Hi")
                    .body1()
                    .foregroundStyle(.textSecondary)
                Text("User")
                    .h6()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            ZStack {
                Image(Icons.bell)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(10)
                    .background(.baseBlack.opacity(0.03))
                    .cornerRadius(1000)
                    .onTapGesture { path = .notifications }
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
        .background(.baseWhite)
        .zIndex(1)
    }

    private var content: some View {
        V2MainViewLayout {
            VStack(spacing: 0) {
                header
                ZStack(alignment: .trailing) {
                    SnapCarouselView(index: $viewModel.currentIndex) {
                        HomeCardView(
                            backgroundGradient: Gradients.greenFirst,
                            title: "Your Device",
                            subtitle: "Your Identity",
                            icon: Icons.rarime,
                            imageContent: {
                                Image(Images.handWithPhone)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.9, anchor: .trailing)
                                    .offset(y: 30)
                            },
                            bottomActions: {
                                Text("* Nothing leaves this device")
                                    .body3()
                                    .foregroundStyle(.textPrimary)
                                    .padding(.leading, 24)
                                    .padding(.bottom, 32)
                            },
                            animation: identityAnimation
                        )
                        .onTapGesture {
                            path = .identity
                        }
                        HomeCardView(
                            backgroundGradient: Gradients.blueFirst,
                            title: "Invite",
                            subtitle: "Others",
                            icon: Icons.rarimo,
                            imageContent: {
                                ZStack(alignment: .leading) {
                                    Image(Images.peopleEmojis)
                                        .resizable()
                                        .scaledToFit()
                                    
                                    Image(Images.claimTokensArrow)
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(0.35)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .offset(x: 70, y: -140)
                                        .matchedGeometryEffect(id: AnimationNamespaceIds.additionalImage, in: inviteFriendsAnimation)
                                }
                            },
                            bottomActions: {
                                VStack(alignment: .leading, spacing: 20) {
                                    copyButton
                                    Text("Copy & Send this invite code")
                                        .body3()
                                        .foregroundStyle(.textPrimary)
                                }
                                .padding(.leading, 24)
                                .padding(.bottom, 32)
                            },
                            animation: inviteFriendsAnimation
                        )
                        .onTapGesture {
                            path = .inviteFriends
                        }
                        HomeCardView(
                            backgroundGradient: Gradients.greenFirst,
                            title: "Claim",
                            subtitle: "10 RMO",
                            icon: Icons.rarimo,
                            imageContent: {
                                Image(Images.rarimoTokens)
                                    .resizable()
                                    .scaledToFit()
                            },
                            bottomActions: {
                                Button(action: { path = .claimTokens }) {
                                    Text("Claim").buttonMedium().fontWeight(.medium)
                                        .frame(height: 48)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 12)
                                }
                                .background(.componentPrimary)
                                .foregroundColor(.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                            },
                            animation: claimTokensAnimation
                        )
                        HomeCardView(
                            backgroundGradient: Gradients.greenSecond,
                            title: "An Unforgettable",
                            subtitle: "Wallet",
                            icon: Icons.rarime,
                            imageContent: {
                                Image(Images.seedPhraseShred)
                                    .resizable()
                                    .scaledToFit()
                            },
                            bottomActions: {
                                Button(action: { path = .wallet }) {
                                    Text("Join early waitlist").buttonMedium().fontWeight(.medium)
                                        .frame(height: 48)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 12)
                                }
                                .background(.componentPrimary)
                                .foregroundColor(.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                            },
                            animation: walletAnimation
                        )
                        HomeCardView(
                            backgroundGradient: Gradients.greenThird,
                            title: "Freedomtool",
                            subtitle: "Voting",
                            icon: Icons.rarime,
                            imageContent: {
                                Image(Images.dotCountry)
                                    .resizable()
                                    .scaledToFit()
                            },
                            bottomActions: {
                                Button(action: {}) {
                                    Text("Scan QR code").buttonMedium().fontWeight(.medium)
                                        .frame(height: 48)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 12)
                                }
                                .background(.componentPrimary)
                                .foregroundColor(.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                            },
                            animation: votingAnimation
                        )
                    }
                    .padding(.horizontal, 22)
                    V2StepIndicator(steps: 5, currentStep: viewModel.currentIndex)
                        .padding(.trailing, 8)
                }
            }
            .background(.baseWhite)
        }
    }
    
    var copyButton: some View {
        HStack(spacing: 16) {
            Text("14925-1592")
                .h6()
                .fontWeight(Font.Weight.bold)
                .foregroundStyle(.textPrimary)
            VerticalDivider(color: .baseBlack.opacity(0.05))
            Image(isCopied ? Icons.check : Icons.copySimple).square(24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.baseWhite)
        .cornerRadius(8)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 230, alignment: .leading)
        .onTapGesture {
            if isCopied { return }
            
            isCopied = true
            FeedbackGenerator.shared.impact(.medium)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
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
