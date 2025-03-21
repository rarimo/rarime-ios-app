import SwiftUI

struct PollView: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var passportManager: PassportManager
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager

    let poll: Poll
    let onClose: () -> Void
    
    @State private var isQuestionsShown = false
    
    @State private var isSubmitting = false
    @State private var isVoted = false
    @State private var isVotedSuccesfully = false
    @State private var isAdmittedToVote = false
    @State private var isUserVoteChecking = false
    
    var body: some View {
        ZStack {
            if isQuestionsShown {
                if poll.status == .started || poll.status == .waiting {
                    ActivePollOptionsView(
                        poll: poll,
                        onSubmit: { results in
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
                                    
                                    isVotedSuccesfully = true
                                    isQuestionsShown = false
                                    AlertManager.shared.emitSuccess(String(localized: "Your vote has been counted"))
                                } catch {
                                    onClose()
                                    LoggerUtil.common.error("Can't submit poll results: \(error, privacy: .public)")
                                    AlertManager.shared.emitError(.unknown(String(localized: "Can't submit poll results")))
                                }
                            }
                        },
                        onClose: { isQuestionsShown = false }
                    )
                } else {
                    ClosedPollResultsView(poll: poll)
                }
            } else {
                pollOverview
            }
        }
    }
    
    private var pollOverview: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .topTrailing) {
                // TODO: use image from ProposalMetadata
                Image(.rewardsTest1)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(maxHeight: 228)
                Button(action: onClose) {
                    Image(Icons.closeFill)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                        .padding(.all, 10)
                }
                .background(.baseWhite)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding([.top, .trailing], 20)
            }
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
                                Text(pollsViewModel.totalParticipants.formatted())
                                    .subtitle7()
                            }
                        }
                        .foregroundStyle(.textSecondary)
                    }
                    Text(poll.description)
                        .body4()
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.leading)
                    Text("\(poll.questions.count) questions")
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Criteria")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    ForEach(pollsViewModel.pollRequirements, id: \.id) { requirement in
                        HStack(alignment: .center, spacing: 8) {
                            Image(requirement.isEligible ? Icons.checkboxCircleFill : Icons.closeCircleFill)
                                .iconMedium()
                                .foregroundStyle(requirement.isEligible ? .secondaryMain : .errorMain)
                            Text(requirement.text)
                                .subtitle6()
                                .foregroundStyle(.textPrimary)
                        }
                    }
                }
                Spacer()
                Group {
                    if poll.status == .started {
                        if passportManager.passport != nil {
                            if isVoted {
                                AppButton(text: "Voted", action: {})
                                    .disabled(true)
                            } else {
                                AppButton(text: "Let's start", action: { isQuestionsShown = true })
                                    .disabled(isSubmitting || !isAdmittedToVote)
                            }
                        } else {
                            AppButton(text: "Verification", action: {})
                        }
                    } else {
                        AppButton(text: "Show results", action: { isQuestionsShown = true })
                    }
                }
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
        }
        .onAppear(perform: checkUserVote)
        .onAppear(perform: checkPollRequirements)
    }
    
    private func checkUserVote() {
        isUserVoteChecking = true
        Task { @MainActor in
            do {
                let nullifier = try userManager.generateNullifierForEvent(poll.eventId.toHex())
                isVoted = try await pollsViewModel.checkUserVote(nullifier)
                isUserVoteChecking = false
            } catch {
                LoggerUtil.common.error("Can't check user vote: \(error, privacy: .public)")
                AlertManager.shared.emitError(.unknown("Can't check user vote"))
            }
        }
    }
    
    private func checkPollRequirements() {
        isAdmittedToVote = pollsViewModel.pollRequirements.allSatisfy { $0.isEligible }
    }
}

#Preview {
    ZStack{}
        .dynamicSheet(isPresented: .constant(true), fullScreen: true) {
            PollView(poll: ACTIVE_POLLS[0], onClose: {})
                .environmentObject(PollsViewModel())
                .environmentObject(UserManager())
                .environmentObject(PassportManager())
                .environmentObject(DecentralizedAuthManager())
        }
}
