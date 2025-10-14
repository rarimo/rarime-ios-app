import SwiftUI

struct InviteOthersView: View {
    let referralCodes: [ReferralCode]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Invite others")
                    .h2()
                    .foregroundStyle(.textPrimary)
                Text("Share your referral link and get bonuses when your friends join")
                    .body3()
                    .frame(maxWidth: 320, alignment: .leading)
                    .foregroundStyle(.textSecondary)
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(referralCodes, id: \.id) { code in
                        InviteCodeView(code: code.id, status: code.status)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct InviteCodeView: View {
    let code: String
    let status: ReferralCodeStatus

    var invitationLink: String {
        ConfigManager.shared.general.webAppURL.appendingPathComponent("r/\(code)").absoluteString
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
                            .foregroundStyle(.textPrimary)
                        Text(invitationLink.dropFirst(8))
                            .body4()
                            .foregroundStyle(.textSecondary)
                        Text("Active")
                            .subtitle7()
                            .foregroundStyle(.successDarker)
                    }
                    Spacer()
                    ShareLink(
                        item: URL(string: invitationLink)!,
                        subject: Text("Invite to Rarimo"),
                        message: Text("Join Rarimo with my invite code: \(code)\n\n\(invitationLink)")
                    ) {
                        Image(.shareLine)
                            .iconMedium()
                            .foregroundStyle(.textPrimary)
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(code)
                            .subtitle6()
                        HStack(spacing: 4) {
                            Text("Used")
                                .body5()
                            Circle()
                                .fill(.bgComponentHovered)
                                .frame(width: 4)
                            Text(usedStatusText)
                                .body5()
                        }
                    }
                    .foregroundStyle(.textSecondary)
                    Spacer()
                    if status == .rewarded {
                        HStack(spacing: 4) {
                            Text(verbatim: "+\(Rewards.invite.formatted())")
                                .subtitle7()
                            Image(.rarimo)
                                .iconSmall()
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .foregroundStyle(.textSecondary)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(status == .active ? .bgComponentPrimary : .clear)
                .overlay {
                    if status != .active {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.bgComponentPrimary, lineWidth: 1)
                    }
                }
        }
    }
}

#Preview {
    InviteOthersView(
        referralCodes: [
            ReferralCode(id: "code1", status: .active),
            ReferralCode(id: "code2", status: .awaiting),
            ReferralCode(id: "code3", status: .banned),
            ReferralCode(id: "code4", status: .consumed),
            ReferralCode(id: "code5", status: .limited),
            ReferralCode(id: "code6", status: .rewarded),
        ]
    )
}
