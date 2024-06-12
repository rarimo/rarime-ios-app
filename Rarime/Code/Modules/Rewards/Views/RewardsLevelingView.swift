import SwiftUI

private struct LevelReward {
    let title: String
    let description: String
    let icon: String
}

private struct PointsLevel {
    let level: Int
    let description: String
    let minPoints: Int
    let maxPoints: Int
    let rewards: [LevelReward]
}

private let pointsLevels: [PointsLevel] = [
    PointsLevel(
        level: 1,
        description: "Reserve tokens to unlock new levels and rewards",
        minPoints: 0,
        maxPoints: 10,
        rewards: [
            LevelReward(
                title: "5 referrals",
                description: "Invite more people, earn more rewards",
                icon: Icons.users
            ),
            LevelReward(
                title: "Rewards campaigns",
                description: "Only level 1 specials",
                icon: Icons.airdrop
            )
        ]
    ),
    PointsLevel(
        level: 2,
        description: "Reserve tokens to unlock new levels and rewards",
        minPoints: 10,
        maxPoints: 30,
        rewards: [
            LevelReward(
                title: "10 extra referrals",
                description: "Invite more people, earn more rewards",
                icon: Icons.users
            ),
            LevelReward(
                title: "Exclusive campaigns",
                description: "Only level 2 specials",
                icon: Icons.airdrop
            )
        ]
    ),
    PointsLevel(
        level: 3,
        description: "Reserve tokens to unlock new levels and rewards",
        minPoints: 30,
        maxPoints: 100,
        rewards: [
            LevelReward(
                title: "20 extra referrals",
                description: "Invite more people, earn more rewards",
                icon: Icons.users
            ),
            LevelReward(
                title: "Exclusive campaigns",
                description: "Only level 3 specials",
                icon: Icons.airdrop
            )
        ]
    )
]

struct RewardsLevelingView: View {
    let userLevel: Int
    let reservedBalance: Double
    @State private var selectedLevelIndex: Int

    init(userLevel: Int, reservedBalance: Double) {
        self.userLevel = userLevel
        self.reservedBalance = reservedBalance
        self._selectedLevelIndex = State(initialValue: userLevel - 1)
    }

    private var selectedLevel: PointsLevel {
        pointsLevels[selectedLevelIndex]
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Leveling")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            CurrentLevelStatus(userLevel: userLevel)
            LevelsSlider(
                selectedIndex: $selectedLevelIndex,
                reservedBalance: reservedBalance
            )
            LevelRewards(rewards: selectedLevel.rewards)
        }
        .background(.backgroundPrimary)
    }
}

private struct CurrentLevelStatus: View {
    let userLevel: Int

    var body: some View {
        HStack {
            ForEach(pointsLevels, id: \.level) { pointsLevel in
                if pointsLevel.level == userLevel {
                    Text(pointsLevel.level.formatted())
                        .body3()
                        .foregroundStyle(.baseBlack)
                        .frame(width: 20, height: 20)
                        .padding(6)
                        .background(.primaryMain, in: Circle())
                } else {
                    Text(pointsLevel.level.formatted())
                        .body3()
                        .foregroundStyle(.textSecondary)
                        .frame(width: 20, height: 20)
                }
                if pointsLevel.level < pointsLevels.count {
                    Spacer()
                    ZStack {}
                        .frame(width: 40, height: 2)
                        .background(
                            LinearGradient(
                                colors: [.textSecondary.opacity(0), .textSecondary.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct LevelsSlider: View {
    @Binding var selectedIndex: Int
    let reservedBalance: Double

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $selectedIndex) {
                ForEach(pointsLevels.indices, id: \.self) { index in
                    LevelItem(
                        level: pointsLevels[index],
                        reservedBalance: reservedBalance
                    )
                    .tag(index)
                }
            }
            .frame(height: 176)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedIndex)
            HStack(spacing: 8) {
                ForEach(0 ..< pointsLevels.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index == selectedIndex ? .primaryMain : .componentPrimary)
                        .frame(width: index == selectedIndex ? 16 : 8, height: 8)
                        .onTapGesture { selectedIndex = index }
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
        }
    }
}

private struct LevelItem: View {
    let level: PointsLevel
    let reservedBalance: Double

    var userBalance: Double {
        min(reservedBalance, Double(level.maxPoints))
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Level \(level.level)")
                        .h5()
                        .foregroundStyle(.textPrimary)
                    Text(level.description)
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                Image(Images.rewardCoin).square(72)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Text(userBalance.formatted())
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text("/\(level.maxPoints)")
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                LinearProgressView(progress: userBalance / Double(level.maxPoints))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 12)
    }
}

private struct LevelRewards: View {
    let rewards: [LevelReward]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rewards")
                .subtitle3()
                .foregroundStyle(.textPrimary)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(rewards, id: \.title) { reward in
                    HStack(spacing: 16) {
                        Image(reward.icon)
                            .iconMedium()
                            .padding(10)
                            .background(.componentPrimary, in: Circle())
                            .foregroundStyle(.textPrimary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reward.title)
                                .subtitle4()
                                .foregroundStyle(.textPrimary)
                            Text(reward.description)
                                .body4()
                                .foregroundStyle(.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
        .ignoresSafeArea()
    }
}

#Preview {
    RewardsLevelingView(
        userLevel: 2,
        reservedBalance: 23.0
    )
}
