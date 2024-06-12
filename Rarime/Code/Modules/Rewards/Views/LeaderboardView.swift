import SwiftUI

// TODO: move to model
struct PointsBalance {
    var id: String
    var amount: Double
    var rank: Int
}

// TODO: move to utils
private func formatBalanceId(_ id: String) -> String {
    let prefix = id.prefix(4)
    let suffix = id.suffix(4)
    return "\(prefix)...\(suffix)"
}

struct LeaderboardView: View {
    let balances: [PointsBalance]
    let myBalance: PointsBalance

    private var otherBalances: [PointsBalance] {
        Array(balances.dropFirst(3))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Leaderboard")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            HStack(alignment: .bottom, spacing: 12) {
                TopLeaderView(balance: balances[1])
                TopLeaderView(balance: balances[0])
                TopLeaderView(balance: balances[2])
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 64)
            .padding(.horizontal, 24)
            BalancesTable(balances: otherBalances, myBalance: myBalance)
        }
        .background(.backgroundPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TopLeaderView: View {
    let balance: PointsBalance

    var height: CGFloat {
        switch balance.rank {
        case 1: 126
        case 2: 100
        default: 84
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(formatBalanceId(balance.id))
                    .caption3()
                    .foregroundStyle(.textSecondary)
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

    var body: some View {
        VStack(spacing: 16) {
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
            HorizontalDivider()
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(balances, id: \.id) { balance in
                        BalanceItem(balance: balance, isMyBalance: balance.id == myBalance.id)
                        HorizontalDivider()
                    }
                }
                Spacer()
            }
            VStack(spacing: 12) {
                HorizontalDivider()
                    .padding(.horizontal, -20)
                BalanceItem(balance: myBalance, isMyBalance: true)
            }
            .padding(.bottom, 8)
        }
        .padding(20)
        .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
        .ignoresSafeArea()
    }
}

private struct BalanceItem: View {
    let balance: PointsBalance
    let isMyBalance: Bool

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
    }
}

#Preview {
    LeaderboardView(
        balances: [
            PointsBalance(id: "mhQeweiAJdiligRt", amount: 8520, rank: 1),
            PointsBalance(id: "12beAoalsOSLals1", amount: 7520, rank: 2),
            PointsBalance(id: "fkdbeweOJdilwq1b", amount: 6520, rank: 3),
            PointsBalance(id: "12beAoalsOSLals1", amount: 5520, rank: 4),
            PointsBalance(id: "12beAoalsOSLals2", amount: 4861, rank: 5),
            PointsBalance(id: "12beAoalsOSLals3", amount: 4520, rank: 6),
            PointsBalance(id: "12beAoalsOSLals4", amount: 3587, rank: 7),
            PointsBalance(id: "12beAoalsOSLals5", amount: 3520, rank: 8),
            PointsBalance(id: "12beAoalsOSLals6", amount: 3320, rank: 9),
            PointsBalance(id: "12beAoalsOSLals7", amount: 3120, rank: 10),
            PointsBalance(id: "mhQeweiAJdiligRw", amount: 2520, rank: 11),
            PointsBalance(id: "12beAoalsOSLalsw", amount: 1820, rank: 12),
            PointsBalance(id: "fkdbeweOJdilwq1w", amount: 920, rank: 13),
            PointsBalance(id: "22beAoalsOSLals1", amount: 820, rank: 14),
            PointsBalance(id: "32beAoalsOSLals2", amount: 761, rank: 15),
            PointsBalance(id: "42beAoalsOSLals3", amount: 720, rank: 16),
            PointsBalance(id: "52beAoalsOSLals4", amount: 687, rank: 17),
            PointsBalance(id: "62beAoalsOSLals5", amount: 620, rank: 18),
            PointsBalance(id: "72beAoalsOSLals6", amount: 520, rank: 19),
            PointsBalance(id: "82beAoalsOSLals7", amount: 420, rank: 20)
        ],
        myBalance: PointsBalance(id: "42beAoalsOSLals3", amount: 4520, rank: 16)
    )
}
