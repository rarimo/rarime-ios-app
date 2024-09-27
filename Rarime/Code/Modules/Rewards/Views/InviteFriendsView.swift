import SwiftUI

private let INVITE_REWARD = 3.0

struct InviteFriendsView: View {
    let balance: PointsBalanceRaw
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(Images.friends)
                .resizable()
                .scaledToFit()
                .frame(width: 240)
                .padding(.top, 136)
            VStack {
                VStack(alignment: .leading, spacing: 32) {
                    Button(action: onBack) {
                        Image(Icons.caretLeft).iconMedium()
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Invite Friends")
                            .h4()
                            .foregroundStyle(.textPrimary)
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                invitedCard
            }
        }
        .background(.backgroundPrimary)
    }

    private var invitedCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                if let codes = balance.referralCodes {
                    Text("Invited \(codes.filter { $0.status != .active }.count)/\(codes.count)")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding(.horizontal, 24)
            ScrollView {
                VStack(spacing: 8) {
                    if let codes = balance.referralCodes {
                        ForEach(codes, id: \.id) { code in
                            InviteCodeView(code: code.id, status: code.status)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.backgroundPure)
        .clipShape(
            .rect(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
        )
        .ignoresSafeArea()
        .padding(.top, 110)
    }
}

private struct InviteCodeView: View {
    let code: String
    let status: ReferralCodeStatus

    var invitationLink: String {
        ConfigManager.shared.api.referralURL.appendingPathComponent("\(code)").absoluteString
    }

    var usedStatusText: String {
        switch status {
            case .awaiting: String(localized: "Scan your passport")
            case .rewarded: String(localized: "Passport scanned")
            case .banned: String(localized: "Unsupported country")
            case .limited: String(localized: "Rewards limit reached")
            default: String(localized: "Need passport scan")
        }
    }

    var body: some View {
        if status == .active {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(code)
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                    Text(invitationLink.dropFirst(8))
                        .body3()
                        .foregroundStyle(.textSecondary)
                    Text("Active")
                        .body4()
                        .foregroundStyle(.successDark)
                }
                Spacer()
                ShareLink(
                    item: URL(string: invitationLink)!,
                    subject: Text("Invite to RariMe"),
                    message: Text("Join RariMe with my invite code: \(code)\n\n\(invitationLink)")
                ) {
                    Image(Icons.share).iconMedium()
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 12))
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(code)
                        .strikethrough()
                        .subtitle4()
                        .foregroundStyle(.textSecondary)
                    HStack(spacing: 4) {
                        Text("Used").body4()
                        Circle()
                            .fill(.componentHovered)
                            .frame(width: 4)
                        Text(usedStatusText)
                            .body4()
                    }
                    .foregroundStyle(.textSecondary)
                }
                Spacer()
                RewardChip(reward: INVITE_REWARD, active: status == .rewarded)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.componentPrimary, lineWidth: 1)
            )
        }
    }
}

#Preview {
    InviteFriendsView(
        balance: PointsBalanceRaw(
            amount: 12,
            isDisabled: false,
            createdAt: Int(Date().timeIntervalSince1970),
            updatedAt: Int(Date().timeIntervalSince1970),
            rank: 12,
            referralCodes: [],
            level: 2,
            isVerified: true
        ),
        onBack: {}
    )
}
