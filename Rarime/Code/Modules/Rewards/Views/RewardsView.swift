import SwiftUI

// TODO: use structs from points service
struct TaskEvent: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let image: String
    let icon: String
    let endDate: Date?
    let reward: Int
}

private let limitedEvents: [TaskEvent] = [
    TaskEvent(
        title: "Initial setup of identity credentials",
        description: "Short description text",
        image: Images.rewardsTest1,
        icon: "",
        endDate: Date(timeIntervalSinceNow: 200000),
        reward: 5
    ),
    TaskEvent(
        title: "Initial setup of identity credentials",
        description: "Short description text",
        image: Images.rewardsTest2,
        icon: "",
        endDate: Date(timeIntervalSinceNow: 500000),
        reward: 5
    )
]

private let activeEvents: [TaskEvent] = [
    TaskEvent(
        title: "Invite 5 users",
        description: "Invite friends in to app",
        image: "",
        icon: Icons.users,
        endDate: nil,
        reward: 5
    ),
    TaskEvent(
        title: "Getting a PoH credential",
        description: "Short description text",
        image: "",
        icon: Icons.identificationCard,
        endDate: nil,
        reward: 5
    )
]

struct RewardsView: View {
    @EnvironmentObject private var userManager: UserManager

    // TODO: use values from points service
    private let currentLevel = 2
    private let nextLevelBalance = 30.0
    private let leaderboardPosition = 241

    var body: some View {
        MainViewLayout {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Text("Rewards")
                            .subtitle2()
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(Icons.trophy).iconSmall()
                            Text(leaderboardPosition.formatted()).subtitle5()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(.warningLighter, in: RoundedRectangle(cornerRadius: 100))
                        .foregroundStyle(.warningDarker)
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
                        Text(userManager.reservedBalance.formatted()).h5()
                    }
                    Spacer()
                    AppButton(text: "Claim", leftIcon: Icons.swap, width: nil, action: {})
                }
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Level \(currentLevel)")
                            .subtitle5()
                            .foregroundStyle(.textPrimary)
                        Image(Icons.caretRight)
                            .iconSmall()
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        Text(String("\(userManager.reservedBalance.formatted())/\(nextLevelBalance.formatted())"))
                            .body4()
                            .foregroundStyle(.textSecondary)
                    }
                    LinearProgressView(progress: userManager.reservedBalance / nextLevelBalance)
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
    let event: TaskEvent

    private var daysRemaining: Int {
        let SECONDS_IN_DAY = 24 * 60 * 60
        let interval = event.endDate!.timeIntervalSince(Date())
        return Int(interval) / SECONDS_IN_DAY
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(event.image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                HStack(spacing: 16) {
                    RewardChip(reward: event.reward)
                    Text("\(daysRemaining) days left")
                        .caption2()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct LinearProgressView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(.componentPrimary)
                    .frame(width: geometry.size.width, height: 8)
                RoundedRectangle(cornerRadius: 100)
                    .fill(
                        LinearGradient(
                            colors: [.primaryMain, .primaryDark, .primaryDarker],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress), height: 8)
            }
        }
    }
}

private struct ActiveEventItem: View {
    let event: TaskEvent

    var body: some View {
        HStack(spacing: 8) {
            Image(event.icon)
                .iconMedium()
                .padding(10)
                .background(.additionalPureDark, in: Circle())
                .foregroundStyle(.baseWhite)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Text(event.description)
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.leading, 8)
            Spacer()
            RewardChip(reward: event.reward)
            Image(Icons.caretRight)
                .iconSmall()
                .foregroundStyle(.textSecondary)
        }
    }
}

struct RewardChip: View {
    let reward: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(String("+\(reward)")).subtitle5()
            Image(Icons.rarimo).iconSmall()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .foregroundStyle(.textSecondary)
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(.componentPrimary)
        )
    }
}

#Preview {
    RewardsView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(UserManager())
}
