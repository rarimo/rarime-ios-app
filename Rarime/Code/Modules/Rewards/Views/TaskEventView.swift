import MarkdownUI
import SwiftUI

struct TaskEventView: View {
    let event: TaskEvent
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(Icons.caretLeft).iconMedium()
                }
                Spacer()
                Button(action: {}) {
                    Image(Icons.share).iconMedium()
                }
            }
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, 20)
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(event.title)
                            .subtitle2()
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 16) {
                            RewardChip(reward: event.reward)
                            if let endDate = event.endDate {
                                Text("Exp: \(DateUtil.richDateFormatter.string(from: endDate))")
                                    .caption2()
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                    }
                    Spacer()
                    Image(event.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                HorizontalDivider().padding(.top, 16)
                ScrollView {
                    Markdown(event.description)
                        .body3()
                        .foregroundStyle(.textPrimary)
                        .padding(.top, 16)
                }
                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            if let actionURL = event.actionURL {
                VStack(spacing: 16) {
                    HorizontalDivider()
                    AppButton(
                        text: "Let's Start",
                        action: {
                            if let url = URL(string: actionURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                    .controlSize(.large)
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    TaskEventView(
        event: TaskEvent(
            title: "Initial setup of identity credentials",
            description: "### Description\n\nThis task is to setup your identity credentials. You will need to provide your personal information and verify your identity.\n\n### Requirements\n\n- Personal Information\n- Identity Verification\n\n### Reward\n\n5 points\n\n### End Date\n\n2021-10-31 23:59:59",
            image: Images.rewardsTest1,
            icon: Icons.airdrop,
            endDate: Date(timeIntervalSinceNow: 200000),
            reward: 5,
            actionURL: "https://example.com"
        ),
        onBack: {}
    )
}
