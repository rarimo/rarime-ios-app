import SwiftUI

private enum RewardsRoute: String, Hashable {
    case taskEvent, inviteFriends, claimRewards
}

struct RewardsView: View {
    @StateObject private var rewardsViewModel = RewardsViewModel()
    @State private var path: [RewardsRoute] = []

    @State private var isLeaderboardSheetShown: Bool = false
    @State private var isLevelingSheetShown: Bool = false

    private var nextLevelBalance: Double {
        let level = pointsLevels.first { $0.level == myBalance.level }
        return level?.maxBalance ?? 0.0
    }

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: RewardsRoute.self) { route in
                switch route {
                case .taskEvent:
                    TaskEventView(onBack: { path.removeLast() })
                        .environmentObject(rewardsViewModel)
                case .inviteFriends:
                    InviteFriendsView(
                        balance: myBalance,
                        onBack: { path.removeLast() }
                    )
                case .claimRewards:
                    ClaimRewardsView(
                        balance: myBalance,
                        onBack: { path.removeLast() }
                    )
                }
            }
        }
    }

    var content: some View {
        MainViewLayout {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Text("Rewards")
                            .subtitle2()
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        Button(action: { isLeaderboardSheetShown = true }) {
                            HStack(spacing: 4) {
                                Image(Icons.trophy).iconSmall()
                                Text(myBalance.rank.formatted()).subtitle5()
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(.warningLighter, in: RoundedRectangle(cornerRadius: 100))
                            .foregroundStyle(.warningDarker)
                        }
                        .dynamicSheet(isPresented: $isLeaderboardSheetShown, fullScreen: true) {
                            LeaderboardView(
                                balances: leaderboardBalances,
                                myBalance: myBalance
                            )
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    VStack(spacing: 8) {
                        balanceCard
                        limitedEventsCard
                        activeEventsCard
                    }
                    .padding(.horizontal, 12)
                }
            }
            .background(.backgroundPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var balanceCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reserved RMO")
                            .body3()
                            .foregroundStyle(.textSecondary)
                        Text(myBalance.amount.formatted()).h5()
                    }
                    Spacer()
                    AppButton(
                        text: "Claim",
                        leftIcon: Icons.swap,
                        width: nil,
                        action: { path.append(.claimRewards) }
                    )
                }
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Level \(myBalance.level)")
                            .subtitle5()
                            .foregroundStyle(.textPrimary)
                        Image(Icons.caretRight)
                            .iconSmall()
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        Text(String("\(myBalance.amount.formatted())/\(nextLevelBalance.formatted())"))
                            .body4()
                            .foregroundStyle(.textSecondary)
                    }
                    .onTapGesture { isLevelingSheetShown = true }
                    .dynamicSheet(isPresented: $isLevelingSheetShown, fullScreen: true) {
                        LevelingView(balance: myBalance)
                    }
                    LinearProgressView(progress: myBalance.amount / nextLevelBalance)
                }
            }
        }
    }

    private var limitedEventsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Text(try! String("🔥"))
                        .subtitle5()
                        .frame(width: 24, height: 24)
                        .background(.warningLight, in: Circle())
                    Text("Limited time events")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                }
                VStack(spacing: 16) {
                    ForEach(limitedEvents) { event in
                        LimitedEventItem(event: event)
                            .onTapGesture {
                                rewardsViewModel.selectedEvent = event
                                path.append(.taskEvent)
                            }
                        if event != limitedEvents.last {
                            HorizontalDivider().padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    private var activeEventsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 20) {
                Text("Active tasks")
                    .subtitle3()
                    .foregroundStyle(.textPrimary)
                VStack(spacing: 16) {
                    ForEach(activeEvents) { event in
                        ActiveEventItem(event: event)
                            .onTapGesture {
                                // TODO: extract to constants
                                if event.meta.name == "invite_friends" {
                                    path.append(.inviteFriends)
                                } else {
                                    rewardsViewModel.selectedEvent = event
                                    path.append(.taskEvent)
                                }
                            }
                        if event != activeEvents.last {
                            HorizontalDivider().padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }
}

private struct LimitedEventItem: View {
    let event: PointsEvent

    private var daysRemaining: Int {
        let SECONDS_IN_DAY = 24 * 60 * 60
        let interval = event.meta.expiresAt!.timeIntervalSince(Date())
        return Int(interval) / SECONDS_IN_DAY
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(event.meta.logo)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 8) {
                Text(event.meta.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                HStack(spacing: 16) {
                    RewardChip(reward: event.meta.reward)
                    Text("\(daysRemaining) days left")
                        .caption2()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActiveEventItem: View {
    let event: PointsEvent

    var body: some View {
        HStack(spacing: 8) {
            Image(event.meta.logo)
                .iconMedium()
                .padding(10)
                .background(.additionalPureDark, in: Circle())
                .foregroundStyle(.baseWhite)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.meta.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Text(event.meta.shortDescription)
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.leading, 8)
            Spacer()
            RewardChip(reward: event.meta.reward)
            Image(Icons.caretRight)
                .iconSmall()
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview {
    RewardsView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(UserManager())
}
