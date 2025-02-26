import SwiftUI

struct V2InviteFriendsView: View {
    let balance: PointsBalanceRaw
    let onClose: () -> Void
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .trailing], 20)
            Image(Images.peopleEmojis)
                .resizable()
                .scaledToFit()
                .padding(.top, 77)
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
            GlassBottomSheet {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top, spacing: 64) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Invite")
                                .h1()
                                .foregroundStyle(.baseBlack)
                                .matchedGeometryEffect(
                                    id: AnimationNamespaceIds.title,
                                    in: animation,
                                    properties: .position
                                )
                            Text("Others")
                                .additional1()
                                .foregroundStyle(.baseBlack.opacity(0.4))
                                .matchedGeometryEffect(
                                    id: AnimationNamespaceIds.subtitle,
                                    in: animation,
                                    properties: .position
                                )
                        }
                        Image(Icons.getTokensArrow)
                            .foregroundStyle(.informationalDark)
                            .padding(.top, 20)
                            .matchedGeometryEffect(
                                id: AnimationNamespaceIds.additionalImage,
                                in: animation
                            )
                    }
                    Text("Share your referral link and get bonuses when your friends join and make a purchase!")
                        .body3()
                        .foregroundStyle(.baseBlack.opacity(0.5))
                    if let codes = balance.referralCodes {
                        VStack(spacing: 8) {
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
            Gradients.gradientSecond
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
                            .h5()
                            .foregroundStyle(.baseBlack)
                        Text(invitationLink.dropFirst(8))
                            .body4()
                            .foregroundStyle(.baseBlack.opacity(0.5))
                        Text("Active")
                            .subtitle7()
                            .foregroundStyle(.successDarker)
                    }
                    Spacer()
                    ShareLink(
                        item: URL(string: invitationLink)!,
                        subject: Text("Invite to RariMe"),
                        message: Text("Join RariMe with my invite code: \(code)\n\n\(invitationLink)")
                    ) {
                        Image(Icons.shareLine).iconMedium().foregroundStyle(.baseBlack)
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(code)
                            .subtitle6()
                        HStack(spacing: 4) {
                            Text("Used").body5()
                            Circle()
                                .fill(.bgComponentHovered)
                                .frame(width: 4)
                            Text(usedStatusText)
                                .body5()
                        }
                    }
                    .foregroundStyle(.baseBlack.opacity(0.5))
                    Spacer()
                    // TODO: sync with RewardChip
                    HStack(spacing: 4) {
                        Text(String("+\(Rewards.invite.formatted())")).subtitle7()
                        Image(Icons.rarimo).iconSmall()
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .foregroundStyle(status == .rewarded ? .successDarker : .baseBlack.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(status == .active ? .bgComponentBasePrimary : .clear)
                .overlay {
                    if status != .active {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.bgComponentBasePrimary, lineWidth: 1)
                    }
                }
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
