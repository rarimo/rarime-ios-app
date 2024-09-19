import SwiftUI

struct LevelingView: View {
    let balance: PointsBalanceRaw
    @State private var selectedLevelIndex: Int

    init(balance: PointsBalanceRaw) {
        self.balance = balance
        self._selectedLevelIndex = State(initialValue: balance.level - 1)
    }

    private var selectedLevel: PointsLevel {
        pointsLevels[selectedLevelIndex]
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Leveling")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            CurrentLevelStatus(userLevel: balance.level)
            LevelsSlider(
                selectedIndex: $selectedLevelIndex,
                reservedBalance: Double(balance.amount)
            )
            LevelRewards(rewards: selectedLevel.rewards)
        }
        .padding(.top, 24)
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
        .onChange(of: selectedIndex) { _ in
            FeedbackGenerator.shared.impact(.light)
        }
    }
}

private struct LevelItem: View {
    let level: PointsLevel
    let reservedBalance: Double

    var userBalance: Double {
        min(reservedBalance, level.maxBalance)
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
                    Text("/\(level.maxBalance.formatted())")
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                LinearProgressView(progress: userBalance / Double(level.maxBalance))
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

                if rewards.isEmpty {
                    Text("Start journey to unlock rewards")
                        .body3()
                        .foregroundStyle(.textSecondary)
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
    LevelingView(
        balance: PointsBalanceRaw(
            amount: 12,
            isDisabled: false,
            createdAt: 1,
            updatedAt: 1,
            rank: 1,
            referralCodes: [],
            level: 1, 
            isVerified: true
        )
    )
}
