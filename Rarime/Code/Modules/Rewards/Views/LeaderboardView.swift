import SwiftUI

// TODO: move to utils
private func formatBalanceId(_ id: String) -> String {
    let prefix = id.prefix(4)
    let suffix = id.suffix(4)
    return "\(prefix)...\(suffix)"
}

struct LeaderboardView: View {
    let balances: [PointsBalance]
    let myBalance: PointsBalance

    var body: some View {
        VStack(spacing: 0) {
            Text("Leaderboard")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            HStack(alignment: .bottom, spacing: 12) {
                TopLeaderView(balance: balances[1], myBalance: myBalance)
                TopLeaderView(balance: balances[0], myBalance: myBalance)
                TopLeaderView(balance: balances[2], myBalance: myBalance)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 64)
            .padding(.horizontal, 24)
            BalancesTable(balances: balances, myBalance: myBalance)
        }
        .padding(.top, 24)
        .background(.backgroundPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TopLeaderView: View {
    let balance: PointsBalance
    let myBalance: PointsBalance

    var height: CGFloat {
        switch balance.rank {
        case 1: 126
        case 2: 100
        default: 84
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 4) {
                Spacer()
                if balance.id == myBalance.id {
                    Text("YOU")
                        .overline3()
                        .foregroundStyle(.textSecondary)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(.componentHovered, in: RoundedRectangle(cornerRadius: 100))
                } else {
                    Text(formatBalanceId(balance.id))
                        .caption3()
                        .foregroundStyle(.textSecondary)
                }
                HStack(spacing: 4) {
                    Text(balance.amount.formatted()).subtitle5()
                    Image(Icons.rarimo).iconSmall()
                }
                .foregroundStyle(.textPrimary)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: height)
            .background(balance.rank == 1 ? .primaryMain : .componentPrimary)
            .clipShape(
                .rect(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 12
                )
            )
            Text("\(balance.rank)")
                .subtitle4()
                .frame(width: 32, height: 32)
                .background(.backgroundPure, in: Circle())
                .foregroundStyle(.textPrimary)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
                .offset(y: -16)
        }
    }
}

private struct BalancesTable: View {
    let balances: [PointsBalance]
    let myBalance: PointsBalance

    private var otherBalances: [PointsBalance] {
        Array(balances.dropFirst(3))
    }

    private var hasMyBalance: Bool {
        balances.first(where: { $0.id == myBalance.id }) != nil
    }

    private func shouldShowDivider(at index: Int) -> Bool {
        let isLast = index == otherBalances.count - 1
        let isBeforeMyBalance = otherBalances[index].id == myBalance.id
        let isAfterMyBalance = !isLast && otherBalances[index + 1].id == myBalance.id

        return !isLast && !isBeforeMyBalance && !isAfterMyBalance
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("PLACE")
                    .overline3()
                    .foregroundStyle(.textSecondary)
                    .frame(width: 64, alignment: .leading)
                Text("INCOGNITO ID")
                    .overline3()
                    .foregroundStyle(.textSecondary)
                Spacer()
                Text("RESERVED")
                    .overline3()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, 16)
            HorizontalDivider()
                .padding(.top, 16)
                .padding(.horizontal, 16)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(otherBalances.indices, id: \.self) { i in
                        BalanceItem(
                            balance: otherBalances[i],
                            isMyBalance: otherBalances[i].id == myBalance.id,
                            highlighted: otherBalances[i].id == myBalance.id
                        )
                        if shouldShowDivider(at: i) {
                            HorizontalDivider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                Spacer()
            }
            if !hasMyBalance {
                VStack(spacing: 0) {
                    HorizontalDivider()
                        .padding(.horizontal, -20)
                    BalanceItem(balance: myBalance, isMyBalance: true)
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 4)
        .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
        .ignoresSafeArea()
    }
}

private struct BalanceItem: View {
    let balance: PointsBalance
    let isMyBalance: Bool
    let highlighted: Bool

    init(balance: PointsBalance, isMyBalance: Bool, highlighted: Bool = false) {
        self.balance = balance
        self.isMyBalance = isMyBalance
        self.highlighted = highlighted
    }

    var body: some View {
        HStack(spacing: 32) {
            Text("\(balance.rank)")
                .subtitle4()
                .foregroundStyle(.textPrimary)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(.componentPrimary, lineWidth: 1))
            HStack(spacing: 16) {
                Text(formatBalanceId(balance.id))
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                if isMyBalance {
                    Text("YOU")
                        .overline3()
                        .foregroundStyle(.textSecondary)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(.componentHovered, in: RoundedRectangle(cornerRadius: 100))
                }
            }
            Spacer()
            HStack(spacing: 4) {
                Text(balance.amount.formatted()).subtitle5()
                Image(Icons.rarimo).iconSmall()
            }
            .foregroundStyle(.textPrimary)
            .padding(.vertical, 2)
            .frame(width: 72)
            .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 48))
        }
        .padding(16)
        .background(highlighted ? .backgroundPrimary : .clear, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    LeaderboardView(
        balances: [
            PointsBalance(id: "mhQeweiAJdiligRt", amount: 85, rank: 1, level: 3),
            PointsBalance(id: "12beAoalsOSLals0", amount: 75, rank: 2, level: 3),
            PointsBalance(id: "fkdbeweOJdilwq1b", amount: 65, rank: 3, level: 3),
            PointsBalance(id: "12beAoalsOSLals1", amount: 55, rank: 4, level: 3),
            PointsBalance(id: "12beAoalsOSLals2", amount: 48, rank: 5, level: 3),
            PointsBalance(id: "12beAoalsOSLals3", amount: 45, rank: 6, level: 3),
            PointsBalance(id: "12beAoalsOSLals4", amount: 35, rank: 7, level: 3),
            PointsBalance(id: "12beAoalsOSLals5", amount: 35, rank: 8, level: 3),
            PointsBalance(id: "12beAoalsOSLals6", amount: 33, rank: 9, level: 3),
            PointsBalance(id: "12beAoalsOSLals7", amount: 31, rank: 10, level: 3),
            PointsBalance(id: "mhQeweiAJdiligRw", amount: 25, rank: 11, level: 2),
            PointsBalance(id: "12beAoalsOSLalsw", amount: 18, rank: 12, level: 2),
            PointsBalance(id: "fkdbeweOJdilwq1w", amount: 15, rank: 13, level: 2),
            PointsBalance(id: "22beAoalsOSLals1", amount: 14, rank: 14, level: 2),
            PointsBalance(id: "32beAoalsOSLals2", amount: 13, rank: 15, level: 2),
            PointsBalance(id: "42beAoalsOSLals3", amount: 12, rank: 16, level: 2),
            PointsBalance(id: "52beAoalsOSLals4", amount: 6, rank: 17, level: 1),
            PointsBalance(id: "62beAoalsOSLals5", amount: 6, rank: 18, level: 1),
            PointsBalance(id: "72beAoalsOSLals6", amount: 5, rank: 19, level: 1),
            PointsBalance(id: "82beAoalsOSLals7", amount: 4, rank: 20, level: 1)
        ],
        myBalance: PointsBalance(id: "82beAoalsOSLalsk", amount: 1, rank: 92, level: 1)
    )
}
