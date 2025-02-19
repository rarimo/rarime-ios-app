import SwiftUI

struct V2InviteFriendsView: View {
    let balance: PointsBalanceRaw
    let onClose: () -> Void
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack {
            ZStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Invite")
                            .h4()
                            .fontWeight(.medium)
                            .foregroundStyle(.textPrimary)
                            .matchedGeometryEffect(id: AnimationNamespaceIds.title, in: animation)
                        Text("Others")
                            .h3()
                            .fontWeight(.semibold)
                            .foregroundStyle(.textSecondary)
                            .matchedGeometryEffect(id: AnimationNamespaceIds.subtitle, in: animation)
                    }
                    .padding(.top, 20)
                    Spacer()
                    Image(Icons.close)
                        .square(20)
                        .foregroundStyle(.baseBlack)
                        .padding(10)
                        .background(.baseBlack.opacity(0.03))
                        .cornerRadius(100)
                        .onTapGesture { onClose() }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                Image(Images.claimTokensArrow)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.35)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(x: 25, y: 80)
                    .matchedGeometryEffect(id: AnimationNamespaceIds.additionalImage, in: animation)
            }
            Image(Images.peopleEmojis)
                .resizable()
                .scaledToFit()
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                .frame(maxHeight: .infinity, alignment: .center)
            if let codes = balance.referralCodes {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Invited \(codes.filter { $0.status != .active }.count)/\(codes.count)")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 4) {
                            ForEach(codes, id: \.id) { code in
                                InviteCodeView(code: code.id, status: code.status)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(
            Gradients.blueFirst
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                .ignoresSafeArea()
        )
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
        Group {
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
                    RewardChip(reward: Rewards.invite, active: status == .rewarded)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(status == .active ? .componentPrimary : .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.componentPrimary, lineWidth: 1)
                )
        }
    }
}

#Preview {
    V2InviteFriendsView(
        balance: PointsBalanceRaw(
            amount: 12,
            isDisabled: false,
            createdAt: Int(Date().timeIntervalSince1970),
            updatedAt: Int(Date().timeIntervalSince1970),
            rank: 12,
            referralCodes: [
                ReferalCode(id: "title 1", status: .active),
                ReferalCode(id: "title 2", status: .awaiting),
                ReferalCode(id: "title 3", status: .banned),
                ReferalCode(id: "title 4", status: .consumed),
                ReferalCode(id: "title 5", status: .limited),
                ReferalCode(id: "title 6", status: .rewarded)
            ],
            level: 2,
            isVerified: true
        ),
        onClose: {},
        animation: Namespace().wrappedValue
    )
}
