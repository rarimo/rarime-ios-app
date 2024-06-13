import MarkdownUI
import SwiftUI

struct TaskEventView: View {
    @EnvironmentObject var rewardsViewModel: RewardsViewModel
    let onBack: () -> Void

    private var event: PointsEvent {
        rewardsViewModel.selectedEvent!
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(Icons.caretLeft).iconMedium()
                }
                Spacer()
                ShareLink(
                    // TODO: update content
                    item: URL(string: "https://rarime.com")!,
                    subject: Text("RariMe Event"),
                    message: Text("RariMe Event: \(event.meta.title)\n\nParticipate and get rewarded: https://rarime.com")
                ) {
                    Image(Icons.share).iconMedium()
                }
            }
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, 20)
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(event.meta.title)
                            .subtitle2()
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 16) {
                            RewardChip(reward: event.meta.reward)
                            if let endDate = event.meta.expiresAt {
                                Text("Exp: \(DateUtil.richDateFormatter.string(from: endDate))")
                                    .caption2()
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                    }
                    Spacer()
                    Image(event.meta.logo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                HorizontalDivider().padding(.top, 16)
                ScrollView {
                    Markdown(event.meta.description)
                        .body3()
                        .foregroundStyle(.textPrimary)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            if let actionURL = event.meta.actionURL {
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
    TaskEventView(onBack: {})
        .environmentObject(RewardsViewModel(
            event: PointsEvent(
                meta: PointsEventMeta(
                    name: "initial_setup",
                    title: "Initial setup of identity credentials",
                    description: "### Description\n\nThis task is to setup your identity credentials. You will need to provide your personal information and verify your identity.\n\n### Requirements\n\n- Personal Information\n- Identity Verification\n\n### Reward\n\n5 points\n\n### End Date\n\n2021-10-31 23:59:59",
                    shortDescription: "",
                    reward: 5,
                    expiresAt: Date(timeIntervalSinceNow: 200000),
                    actionURL: "https://example.com",
                    logo: Images.rewardsTest1
                )
            )
        ))
}
