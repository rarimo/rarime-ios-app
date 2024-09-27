import SwiftUI

// TODO: move to utils
private func formatBalanceId(_ id: String) -> String {
    let prefix = id.prefix(4)
    let suffix = id.suffix(4)
    return "\(prefix)...\(suffix)"
}

struct LeaderboardView: View {
    let balances: [LeaderboardEntry]
    let myBalance: PointsBalanceRaw
    let totalParticipants: Int

    var body: some View {
        VStack(spacing: 0) {
            Text("Leaderboard")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            Text("\(totalParticipants.formatted()) participants")
                .caption3()
                .foregroundStyle(.textSecondary)
                .padding(.top, 2)
            HStack(alignment: .bottom, spacing: 12) {
                if balances.count > 3 {
                    TopLeaderView(balance: balances[1], myBalance: myBalance)
                    TopLeaderView(balance: balances[0], myBalance: myBalance)
                    TopLeaderView(balance: balances[2], myBalance: myBalance)
                }
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
    let balance: LeaderboardEntry
    let myBalance: PointsBalanceRaw

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
                    Text(formatBalanceId(balance.id ?? ""))
                        .caption3()
                        .foregroundStyle(balance.rank == 1 ? .baseBlack.opacity(0.5) : .textSecondary)
                }
                HStack(spacing: 4) {
                    Text(balance.amount.formatted())
                        .subtitle5()
                    Image(Icons.rarimo)
                        .iconSmall()
                }
                .foregroundStyle(balance.rank == 1 ? .baseBlack : .textPrimary)
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
    let balances: [LeaderboardEntry]
    let myBalance: PointsBalanceRaw

    private var otherBalances: [LeaderboardEntry] {
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
                ScrollViewReader { scrollView in
                    VStack(spacing: 0) {
                        ForEach(otherBalances.indices, id: \.self) { i in
                            BalanceItem(
                                balance: otherBalances[i],
                                isMyBalance: otherBalances[i].id == myBalance.id,
                                highlighted: otherBalances[i].id == myBalance.id
                            )
                            .id(otherBalances[i].id)
                            if shouldShowDivider(at: i) {
                                HorizontalDivider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .onAppear {
                        if hasMyBalance {
                            scrollView.scrollTo(myBalance.id, anchor: .center)
                        }
                    }
                    Spacer()
                }
            }
            if !hasMyBalance {
                VStack(spacing: 0) {
                    HorizontalDivider()
                        .padding(.horizontal, -20)
                    BalanceItem(balance: myBalance.toLeaderboardEntry(), isMyBalance: true)
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
    let balance: LeaderboardEntry
    let isMyBalance: Bool
    let highlighted: Bool

    init(balance: LeaderboardEntry, isMyBalance: Bool, highlighted: Bool = false) {
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
                Text(formatBalanceId(balance.id ?? ""))
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
        balances: [],
        myBalance: PointsBalanceRaw(
            amount: 12,
            isDisabled: false,
            createdAt: Int(Date().timeIntervalSince1970),
            updatedAt: Int(Date().timeIntervalSince1970),
            rank: 12,
            referralCodes: [],
            level: 2,
            isVerified: true
        ),
        totalParticipants: 35567
    )
}
