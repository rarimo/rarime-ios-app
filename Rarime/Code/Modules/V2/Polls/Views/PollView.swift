import SwiftUI

struct PollView: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var passportManager: PassportManager
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager

    let poll: Poll
    let onClose: () -> Void
    
    @State private var isSubmitting = false
    
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
                                Text(pollsViewModel.pollTotalParticipants.formatted())
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
                        ActivePollOptionsView(poll: poll, onSubmit: { results in
                            isSubmitting = true
                            Task { @MainActor in
                                defer { isSubmitting = false }
                                do {
                                    guard let user = userManager.user else { return }
                                    let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
                                    
                                    try await pollsViewModel.vote(
                                        accessJwt,
                                        user,
                                        userManager.registerZkProof!,
                                        passportManager.passport!,
                                        results
                                    )
                                } catch {
                                    LoggerUtil.common.error("Can't submit poll results: \(error, privacy: .public)")
                                    AlertManager.shared.emitError(.unknown(String(localized: "Can't submit poll results")))
                                }
                            }
                        })
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
        .environmentObject(PollsViewModel())
        .environmentObject(UserManager())
        .environmentObject(PassportManager())
        .environmentObject(DecentralizedAuthManager())
}
