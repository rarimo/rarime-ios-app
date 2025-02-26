import SwiftUI

struct PollView: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    
    let poll: Poll

    let onClose: () -> Void
    
    @State private var isSubmitting = false
    
    var totalParticipants: Int {
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            AppIconButton(icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(poll.title)
                            .h3()
                            .foregroundStyle(.textPrimary)
                            .multilineTextAlignment(.leading)
                        HStack(alignment: .center, spacing: 12) {
                            HStack(alignment: .center, spacing: 8) {
                                Image(Icons.timerLine)
                                    .iconSmall()
                                Text(poll.endAt)
                                    .subtitle7()
                            }
                            HStack(alignment: .center, spacing: 8) {
                                Image(Icons.groupLine)
                                    .iconSmall()
                                Text(totalParticipants.formatted())
                                    .subtitle7()
                            }
                        }
                        .foregroundStyle(.textSecondary)
                    }
                    Text(poll.description)
                        .body4()
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                HorizontalDivider()
                VStack(alignment: .leading, spacing: 16) {
                    if poll.status == .started || poll.status == .waiting {
                        ActivePollOptionsView(poll: poll, onSubmit: { _ in })
                    } else {
                        ClosedPollResultsView(poll: poll)
                    }
                }
            }
        }
        .padding([.top, .horizontal], 20)
    }
}

#Preview {
    PollView(poll: ACTIVE_POLLS[0], onClose: {})
        .environmentObject(PollsViewModel(poll: ACTIVE_POLLS[0]))
}

