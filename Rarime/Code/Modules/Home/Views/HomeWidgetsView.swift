import Alamofire
import SwiftUI

struct HomeWidgetsView: View {
    @EnvironmentObject private var likenessManager: LikenessManager

    @EnvironmentObject private var homeViewModel: HomeView.ViewModel
    @EnvironmentObject private var findFaceViewModel: FindFaceViewModel
    @EnvironmentObject private var pollsViewModel: PollsViewModel

    let namespaceProvider: (HomeCardId) -> Namespace.ID
    let onSelect: (HomeCardId) -> Void

    @State private var currentIndex: Int = 0
    @State private var isCopied = false

    private var activeReferralCode: String? {
        homeViewModel.pointsBalance?.referralCodes?
            .filter { $0.status == .active }
            .first?.id
    }

    private var userPointsBalance: Int {
        homeViewModel.pointsBalance?.amount ?? 0
    }

    private var isBalanceSufficient: Bool {
        homeViewModel.pointsBalance != nil && userPointsBalance > 0
    }

    private var homeCards: [HomeCarouselCard] {
        [
            HomeCarouselCard(action: { onSelect(.recovery) }) {
                HomeCardView(
                    foregroundGradient: Gradients.darkGreenText,
                    foregroundColor: .invertedDark,
                    topIcon: Icons.rarime,
                    bottomIcon: Icons.arrowRightUpLine,
                    imageContent: {
                        Image(.recoveryShieldBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Recovery",
                    subtitle: "Method",
                    bottomContent: {
                        Text("Set up a new way to recover your account")
                            .body4()
                            .foregroundStyle(.textSecondary)
                            .frame(maxWidth: 220, alignment: .leading)
                            .padding(.top, 12)
                    },
                    animation: namespaceProvider(.recovery)
                )
            },
            HomeCarouselCard(
                isVisible: findFaceViewModel.user != nil && findFaceViewModel.user?.celebrity.status != .maintenance,
                action: { onSelect(.findFace) }
            ) {
                HomeCardView(
                    foregroundGradient: Gradients.purpleText,
                    foregroundColor: .invertedDark,
                    topIcon: Icons.rarime,
                    bottomIcon: Icons.arrowRightUpLine,
                    imageContent: {
                        Image(.findFaceBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Hidden keys",
                    subtitle: "Find a face",
                    topContent: {
                        FindFaceStatusChip(status: findFaceViewModel.user?.celebrity.status ?? .maintenance)
                    },
                    animation: namespaceProvider(.findFace)
                )
            },
            HomeCarouselCard(
                isVisible: pollsViewModel.hasVoted,
                action: { onSelect(.freedomTool) }
            ) {
                HomeCardView(
                    backgroundGradient: Gradients.gradientFifth,
                    topIcon: Icons.freedomtool,
                    bottomIcon: Icons.arrowRightUpLine,
                    imageContent: {
                        Image(.dotCountry)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 20)
                    },
                    title: "Freedomtool",
                    subtitle: "Voting",
                    animation: namespaceProvider(.freedomTool)
                )
            },
            HomeCarouselCard(
                // TODO: make it visible when likeness is ready
                isVisible: false,
                action: {
                    if !likenessManager.isLoading {
                        onSelect(.likeness)
                    }
                }
            ) {
                HomeCardView(
                    backgroundGradient: Gradients.purpleBg,
                    foregroundGradient: Gradients.purpleText,
                    topIcon: Icons.rarime,
                    bottomIcon: Icons.arrowRightUpLine,
                    imageContent: {
                        if let faceImage = likenessManager.faceImage {
                            LikenessFaceImageView(image: faceImage)
                                .padding(.top, 80)
                        } else {
                            Image(.likenessFace)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.75)
                        }
                    },
                    title: likenessManager.isRegistered ? nil : "Digital likeness",
                    subtitle: likenessManager.isRegistered ? nil : "Set a rule",
                    bottomContent: { likenessBottomContent },
                    animation: namespaceProvider(.likeness)
                )
            },
            HomeCarouselCard(
                isVisible: isBalanceSufficient,
                action: { onSelect(.claimTokens) }
            ) {
                HomeCardView(
                    backgroundGradient: Gradients.gradientThird,
                    topIcon: Icons.rarimo,
                    bottomIcon: Icons.arrowRightUpLine,
                    imageContent: {
                        Image(.rarimoTokens)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 100)
                    },
                    title: isBalanceSufficient ? "Reserved" : "Upcoming",
                    subtitle: isBalanceSufficient ? "\(userPointsBalance) RMO" : "RMO",
                    animation: namespaceProvider(.claimTokens)
                )
            },
            HomeCarouselCard(
                isVisible: !homeViewModel.isBalanceFetching && homeViewModel.pointsBalance != nil,
                action: { onSelect(.inviteFriends) }
            ) {
                HomeCardView(
                    backgroundGradient: Gradients.gradientSecond,
                    topIcon: Icons.rarime,
                    bottomIcon: Icons.arrowRightUpLine,
                    imageContent: {
                        ZStack(alignment: .bottomTrailing) {
                            Image(.peopleEmojis)
                                .resizable()
                                .scaledToFit()
                                .padding(.top, 84)

                            Image(Icons.getTokensArrow)
                                .foregroundStyle(.informationalDark)
                                .offset(x: -44, y: 88)
                                .matchedGeometryEffect(
                                    id: AnimationNamespaceIds.additionalImage,
                                    in: namespaceProvider(.inviteFriends)
                                )
                        }
                    },
                    title: "Invite",
                    subtitle: "Others",
                    bottomContent: { inviteFriendsBottomContent },
                    animation: namespaceProvider(.inviteFriends)
                )
            },
        ]
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            SnapCarouselView(
                index: $currentIndex,
                cards: homeCards.filter { $0.isVisible },
                spacing: 30,
                trailingSpace: 20
            )
            .padding(.horizontal, 22)
            if homeCards.count > 1 {
                VerticalStepIndicator(
                    steps: homeCards.filter(\.isVisible).count,
                    currentStep: currentIndex
                )
                .padding(.trailing, 8)
            }
        }
    }

    private var likenessBottomContent: some View {
        ZStack {
            if likenessManager.isRegistered {
                VStack(alignment: .leading, spacing: 0) {
                    Text("My Rule:")
                        .h5()
                        .foregroundStyle(Gradients.purpleText)
                        .padding(.bottom, 12)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.extra,
                            in: namespaceProvider(.likeness),
                            properties: .position
                        )
                    Text(likenessManager.rule.title)
                        .additional1()
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Gradients.purpleText)
                        .frame(maxWidth: 306, alignment: .leading)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.subtitle,
                            in: namespaceProvider(.likeness),
                            properties: .position
                        )
                }
            } else {
                Text("First human-AI Contract")
                    .body4()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                    .padding(.top, 12)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.extra,
                        in: namespaceProvider(.likeness),
                        properties: .position
                    )
            }
        }
    }

    private var inviteFriendsBottomContent: some View {
        ZStack {
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
        }
    }
}

#Preview {
    HomeWidgetsView(
        namespaceProvider: { _ in Namespace().wrappedValue },
        onSelect: { _ in }
    )
    .environmentObject(LikenessManager())
    .environmentObject(HomeView.ViewModel())
    .environmentObject(FindFaceViewModel())
    .environmentObject(PollsViewModel())
}
