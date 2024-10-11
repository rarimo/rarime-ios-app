import CachedAsyncImage
import SwiftUI

private enum RewardsRoute: String, Hashable {
    case taskEvent, inviteFriends, claimRewards
}

struct RewardsView: View {
    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    
    @StateObject private var rewardsViewModel = RewardsViewModel()
    @State private var path: [RewardsRoute] = []
    
    @State private var isCodeVerified = false
    @State private var isRewardsLoaded = false
    @State private var isEventsLoaded = false
    @State private var isLeaderboardLoaded = false
    @State private var isLeaderboardSheetShown: Bool = false
    @State private var isLevelingSheetShown: Bool = false
    
    var limitedEvents: [GetEventResponseData] {
        rewardsViewModel.events.filter { $0.attributes.meta.metaStatic.expiresAt != nil }
    }
    
    var notlimitedEvents: [GetEventResponseData] {
        var events = rewardsViewModel
            .events
            .filter { $0.attributes.meta.metaStatic.expiresAt == nil }
        
        if let user = userManager.user {
            if user.status != .unscanned {
                events = events.filter { $0.attributes.meta.metaStatic.name != EventNames.passportScan.rawValue }
            }
        }
        
        return events
    }

    private var nextLevelBalance: Double {
        let myBalance = rewardsViewModel.pointsBalanceRaw!
        
        let level = pointsLevels.first { $0.level == myBalance.level }
        return level?.maxBalance ?? 0.0
    }
    
    private var isUnsupportedCountry: Bool {
        passportManager.passport != nil && passportManager.isUnsupportedForRewards
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                content.navigationDestination(for: RewardsRoute.self) { route in
                    switch route {
                    case .taskEvent:
                        TaskEventView(onBack: { path.removeLast() })
                            .environmentObject(rewardsViewModel)
                    case .inviteFriends:
                        ZStack {
                            if let myBalance = rewardsViewModel.pointsBalanceRaw {
                                InviteFriendsView(
                                    balance: myBalance,
                                    onBack: { path.removeLast() }
                                )
                            }
                        }
                    case .claimRewards:
                        ClaimRewardsView(
                            balance: myBalance,
                            onBack: { path.removeLast() }
                        )
                    }
                }
            }
        }
        .environmentObject(rewardsViewModel)
    }

    var content: some View {
        MainViewLayout {
            if isCodeVerified {
                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            Text("Rewards")
                                .subtitle2()
                                .foregroundStyle(.textPrimary)
                            Spacer()
                            if !isUnsupportedCountry {
                                VStack {
                                    if let balance = rewardsViewModel.pointsBalanceRaw {
                                        Button(action: { isLeaderboardSheetShown = true }) {
                                            HStack(spacing: 4) {
                                                Image(Icons.trophy).iconSmall()
                                                Text("\(balance.rank ?? 0)").subtitle5()
                                            }
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(.warningLighter, in: RoundedRectangle(cornerRadius: 100))
                                            .foregroundStyle(.warningDarker)
                                        }
                                        .dynamicSheet(isPresented: $isLeaderboardSheetShown, fullScreen: true) {
                                            ZStack {
                                                LeaderboardView(
                                                    balances: rewardsViewModel.leaderboard,
                                                    myBalance: balance,
                                                    totalParticipants: rewardsViewModel.totalParticipants
                                                )
                                            }
                                        }
                                    }
                                }
                                .isLoading(!isLeaderboardLoaded)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        if isUnsupportedCountry {
                            VStack(spacing: 8) {
                                Text(passportManager.passportCountry.flag)
                                    .h4()
                                    .frame(width: 72, height: 72)
                                    .background(.componentPrimary, in: Circle())
                                    .foregroundStyle(.textPrimary)
                                Text("Unsupported country")
                                    .h5()
                                    .foregroundStyle(.textPrimary)
                                    .padding(.top, 16)
                                Text("Unfortunately, these passports are not eligible for rewards. However, you can use your incognito ID for other upcoming mini apps.")
                                    .body3()
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.textSecondary)
                            }
                            .padding(.top, 120)
                            .padding(.horizontal, 32)
                        } else {
                            VStack(spacing: 8) {
                                balanceCard
                                if !limitedEvents.isEmpty {
                                    limitedEventsCard(limitedEvents)
                                }
                                activeEventsCard
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.bottom, 124)
                }
                .background(.backgroundPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .isLoading(!isRewardsLoaded)
                .onAppear(perform: fetchEvents)
                .onAppear(perform: fetchLeaderboard)
            } else {
                RewardsIntroView {
                    isCodeVerified = true
                }
                .onAppear {
                    isCodeVerified = userManager.user?.userReferralCode != nil
                }
            }
        }
    }

    private var balanceCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                if let balance = rewardsViewModel.pointsBalanceRaw {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reserved RMO")
                                .body3()
                                .foregroundStyle(.textSecondary)
                            Text(balance.amount.formatted()).h5()
                        }
                        Spacer()
                        AppButton(
                            text: "Claim",
                            leftIcon: Icons.swap,
                            width: nil,
                            action: { path.append(.claimRewards) }
                        )
                        .disabled(true)
                    }
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Level \(balance.level)")
                                .subtitle5()
                                .foregroundStyle(.textPrimary)
                            Image(Icons.caretRight)
                                .iconSmall()
                                .foregroundStyle(.textPrimary)
                            Spacer()
                            Text(String("\(balance.amount.formatted())/\(nextLevelBalance.formatted())"))
                                .body4()
                                .foregroundStyle(.textSecondary)
                        }
                        .onTapGesture { isLevelingSheetShown = true }
                        .dynamicSheet(isPresented: $isLevelingSheetShown, fullScreen: true) {
                            LevelingView(balance: balance)
                        }
                        LinearProgressView(progress: Double(balance.amount) / nextLevelBalance)
                    }
                }
            }
        }
    }

    func limitedEventsCard(_ events: [GetEventResponseData]) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Text(verbatim: "🔥")
                        .subtitle5()
                        .frame(width: 24, height: 24)
                        .background(.warningLight, in: Circle())
                    Text("Limited time events")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                }
                VStack(spacing: 16) {
                    if isEventsLoaded {
                        ForEach(events, id: \.id) { event in
                            VStack {
                                LimitedEventItem(event: event)
                                    .onTapGesture {
                                        rewardsViewModel.selectedEvent = event
                                        path.append(.taskEvent)
                                    }
                            }
                        }
                    } else {
                        ProgressView()
                            .controlSize(.large)
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
                    ForEach(notlimitedEvents.reversed(), id: \.id) { event in
                        ActiveEventItem(event: event)
                            .onTapGesture {
                                if event.attributes.meta.metaStatic.name == EventNames.referralCommon.rawValue {
                                    path.append(.inviteFriends)
                                } else if event.attributes.meta.metaStatic.name == EventNames.passportScan.rawValue {
                                    mainViewModel.isRewardsSheetPresented = true
                                    mainViewModel.selectedTab = .home
                                } else {
                                    rewardsViewModel.selectedEvent = event
                                    path.append(.taskEvent)
                                }
                            }
                    }
                    if notlimitedEvents.isEmpty {
                        Text("No active tasks")
                            .body3()
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
        }
    }
        
    func fetchEvents() {
        Task { @MainActor in
            do {
                guard let user = userManager.user else { throw "user is not initalized" }
                    
                if user.userReferralCode == nil {
                    return
                }
                                    
                let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
                    
                let points = Points(ConfigManager.shared.api.pointsServiceURL)
                    
                let balanceResponse = try await points.getPointsBalance(accessJwt, true, true)
                    
                self.rewardsViewModel.pointsBalanceRaw = balanceResponse.data.attributes
                isRewardsLoaded = true

                let events = try await points.listEvents(
                    accessJwt,
                    filterMetaStaticName: [
                        EventNames.passportScan.rawValue,
                        EventNames.referralCommon.rawValue
                    ]
                )

                self.rewardsViewModel.events = events.data

                self.isEventsLoaded = true
            } catch {
                LoggerUtil.common.error("failed to fetch events: \(error, privacy: .public)")
                    
                AlertManager.shared.emitError(.unknown("Unable to fetch events, try again later"))
            }
        }
    }
        
    func fetchLeaderboard() {
        Task { @MainActor in
            do {
                let points = Points(ConfigManager.shared.api.pointsServiceURL)
                    
                let leaderboard = try await points.getLeaderboard(50, 0)
                    
                self.rewardsViewModel.leaderboard = leaderboard.data.map { entry in
                    entry.attributes
                }
                self.rewardsViewModel.totalParticipants = leaderboard.meta.eventsCount
                    
                self.isLeaderboardLoaded = true
            } catch {
                LoggerUtil.common.error("failed to fetch leaderboard: \(error, privacy: .public)")
                    
                AlertManager.shared.emitError(.unknown("Unable to fetch leaderboard, try again later"))
            }
        }
    }
}

private struct LimitedEventItem: View {
    let event: GetEventResponseData

    private var daysRemaining: Int {
        let SECONDS_IN_DAY = 24 * 60 * 60
            
        let interval = event.attributes.meta.metaStatic.expiresAt!.timeIntervalSince(Date())
            
        return Int(interval) / SECONDS_IN_DAY
    }

    var body: some View {
        HStack(spacing: 16) {
            CachedAsyncImage(
                url: URL(string: event.attributes.meta.metaStatic.logo ?? ""),
                content: { completion in
                    if let image = completion.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.additionalPureDark)
                    }
                }
            )
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 8) {
                Text(event.attributes.meta.metaStatic.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                HStack(spacing: 16) {
                    RewardChip(reward: Double(event.attributes.meta.metaStatic.reward))
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
    let event: GetEventResponseData

    var body: some View {
        HStack(spacing: 8) {
            CachedAsyncImage(
                url: URL(string: event.attributes.meta.metaStatic.logo ?? ""),
                content: { completion in
                    if let image = completion.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(.additionalPureDark)
                    }
                }
            )
            .frame(width: 40, height: 40)
            .background(.additionalPureDark, in: Circle())
            .foregroundStyle(.baseWhite)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(event.attributes.meta.metaStatic.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Text(event.attributes.meta.metaStatic.shortDescription)
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.leading, 8)
            Spacer()
            RewardChip(reward: Double(event.attributes.meta.metaStatic.reward))
            Image(Icons.caretRight)
                .iconSmall()
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview {
    let userManager = UserManager()
        
    return RewardsView()
        .environmentObject(DecentralizedAuthManager())
        .environmentObject(MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(userManager)
        .onAppear(perform: {
            try? userManager.createNewUser()
        })
}
