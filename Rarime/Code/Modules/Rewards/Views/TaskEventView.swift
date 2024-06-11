import SwiftUI

struct TaskEventView: View {
    let event: TaskEvent
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 32) {
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
            VStack(spacing: 24) {
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
                HorizontalDivider()
                Text(event.description)
                    .body3()
                    .foregroundStyle(.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            VStack(spacing: 16) {
                HorizontalDivider()
                AppButton(text: "Let's Start", action: {})
                    .controlSize(.large)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    TaskEventView(
        event: TaskEvent(
            title: "Initial setup of identity credentials",
            description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.Є",
            image: Images.rewardsTest1,
            icon: Icons.airdrop,
            endDate: Date(timeIntervalSinceNow: 200000),
            reward: 5
        ),
        onBack: {}
    )
}
