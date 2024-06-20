import CachedAsyncImage
import MarkdownUI
import SwiftUI

struct TaskEventView: View {
    @EnvironmentObject var rewardsViewModel: RewardsViewModel

    let onBack: () -> Void

    private var event: GetEventResponseData {
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
                    message: Text("RariMe Event: \(event.attributes.meta.metaStatic.title)\n\nParticipate and get rewarded: https://rarime.com")
                ) {
                    Image(Icons.share).iconMedium()
                }
            }
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, 20)
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(event.attributes.meta.metaStatic.title)
                            .subtitle2()
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 16) {
                            RewardChip(reward: Double(event.attributes.meta.metaStatic.reward))
                            if let endDate = event.attributes.meta.metaStatic.expiresAt {
                                Text("Exp: \(DateUtil.richDateFormatter.string(from: endDate))")
                                    .caption2()
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                    }
                    Spacer()
                    CachedAsyncImage(url: URL(string: event.attributes.meta.metaStatic.logo ?? "")) { completion in
                        if let image = completion.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.componentPrimary)
                        }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                HorizontalDivider().padding(.top, 16)
                ScrollView {
                    Markdown(event.attributes.meta.metaStatic.description)
                        .body3()
                        .foregroundStyle(.textPrimary)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            if let actionURL = event.attributes.meta.metaStatic.actionURL {
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
            event: GetEventResponseData(
                id: "",
                type: "",
                attributes: GetEventResponseAttributes(
                    status: "active",
                    createdAt: Int(Date().timeIntervalSince1970),
                    updatedAt: Int(Date().timeIntervalSince1970),
                    meta: GetEventResponseMeta(
                        metaStatic: GetEventResponseStatic(
                            name: "",
                            reward: 5,
                            title: "lorem",
                            description: "lorem",
                            shortDescription: "lorem",
                            frequency: "one-time",
                            startsAt: Date(),
                            expiresAt: Date(),
                            actionURL: "https://example.com",
                            logo: "https://storage.googleapis.com/rarimo-store/rarime-img/invite_friends.png"
                        )
                    ),
                    pointsAmount: nil
                )
            )
        ))
}
