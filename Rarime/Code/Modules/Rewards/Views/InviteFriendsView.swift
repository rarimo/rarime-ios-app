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
                        Text("Short description text here")
                            .body2()
                            .foregroundStyle(.textSecondary)
                    }
                }
                .padding(20)
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
                    Text("Invited \(codes.filter { $0.status == .rewarded }.count)/\(codes.count)")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                }
                Text("Short description text here")
                    .body3()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, 24)
            ScrollView {
                VStack(spacing: 8) {
                    if let codes = balance.referralCodes {
                        ForEach(codes, id: \.id) { code in
                            InviteCodeView(code: code.id, status: .active)
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

private enum InviteCodeStatus {
    case active, activated, used
}

private struct InviteCodeView: View {
    let code: String
    let status: ReferralCodeStatus

    var invitationLink: String {
        // TODO: use URL from config
        "https://app.rarime.com/i/\(code)"
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
                    // TODO: update content
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
                        Text(status == .rewarded ? "Passport scanned" : "Need passport scan")
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
            level: 2
        ),
        onBack: {}
    )
}
