import Alamofire
import SwiftUI

struct PollView: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var passportManager: PassportManager
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager

    let poll: Poll
    let onClose: () -> Void
    let onVerification: () -> Void
    
    @State private var isQuestionsShown = false
    @State private var isSubmitting = false
    @State private var isVoted = false
    @State private var isAdmittedToVote = false
    @State private var isUserVoteChecking = false
    
    private var totalParticipants: Int {
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
    var body: some View {
        if isQuestionsShown {
            if (poll.rankingBased) {
                RankingBasedVoteView(
                    selectedPoll: poll,
                    onBackClick: { isQuestionsShown = false },
                    onClick: { results in
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
                                
                                if !pollsViewModel.votingPollsIds.contains(Int(poll.id)) {
                                    pollsViewModel.votingPollsIds.append(Int(poll.id))
                                }

                                isQuestionsShown = false
                                AlertManager.shared.emitSuccess(String(localized: "Your vote has been counted"))
                            } catch {
                                LoggerUtil.common.error("Can't submit poll results: \(error, privacy: .public)")

                                guard let error = error as? AFError else {
                                    AlertManager.shared.emitError(.unknown(error.localizedDescription))
                                    return
                                }
                                
                                let openApiHttpCode = try error.retriveOpenApiHttpCode()
                                let serverError = openApiHttpCode == HTTPStatusCode.forbidden.rawValue
                                ? Errors.unknown("The maximum number of participants has been reached, contact the poll owner")
                                : Errors.unknown("Service unavailable, try again later. Status code: \(openApiHttpCode)")
                                
                                AlertManager.shared.emitError(serverError)
                            }
                        }
                    }
                )
            }
            else {
                ActivePollOptionsView(
                    poll: poll,
                    isSubmitting: isSubmitting,
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
                                
                                if !pollsViewModel.votingPollsIds.contains(Int(poll.id)) {
                                    pollsViewModel.votingPollsIds.append(Int(poll.id))
                                }
                                
                                isQuestionsShown = false
                                AlertManager.shared.emitSuccess(String(localized: "Your vote has been counted"))
                                onClose()
                            } catch {
                                LoggerUtil.common.error("Can't submit poll results: \(error, privacy: .public)")
                                
                                guard let error = error as? AFError else {
                                    AlertManager.shared.emitError(.unknown(error.localizedDescription))
                                    onClose()
                                    return
                                }
                                
                                let openApiHttpCode = try error.retriveOpenApiHttpCode()
                                let serverError = openApiHttpCode == HTTPStatusCode.forbidden.rawValue
                                ? Errors.unknown("The maximum number of participants has been reached, contact the poll owner")
                                : Errors.unknown("Service unavailable, try again later. Status code: \(openApiHttpCode)")
                                
                                AlertManager.shared.emitError(serverError)
                                onClose()
                            }
                        }
                    },
                    onClose: { isQuestionsShown = false }
                )
            }
        } else {
            pollOverview
        }
    }
    
    private var pollOverview: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .topTrailing) {
                if let image = poll.image {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                            .clipped()
                    }
                    .frame(height: 228)
                }
                Button(action: onClose) {
                    Image(.closeFill)
                        .iconMedium()
                        .foregroundStyle(.baseBlack)
                        .padding(.all, 10)
                }
                .background(.baseWhite)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .frame(maxWidth: .infinity, alignment: .trailing)
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
                                Image(.timerLine)
                                    .iconSmall()
                                Text(poll.endAt)
                                    .subtitle7()
                            }
                            HStack(alignment: .center, spacing: 8) {
                                Image(.groupLine)
                                    .iconSmall()
                                Text(totalParticipants.formatted())
                                    .subtitle7()
                            }
                        }
                        .foregroundStyle(.textSecondary)
                    }
                    if(!poll.rankingBased){
                        Group {
                            Text(poll.description)
                                .multilineTextAlignment(.leading)
                            Text("\(poll.questions.count) questions")
                        }
                        .body4()
                        .foregroundStyle(.textSecondary)
                    }
                }
                if !pollsViewModel.pollRequirements.isEmpty {
                    HorizontalDivider()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Criteria")
                            .overline2()
                            .foregroundStyle(.textSecondary)
                        ForEach(pollsViewModel.pollRequirements, id: \.id) { requirement in
                            HStack(alignment: .center, spacing: 8) {
                                Image(requirement.isEligible ? .checkboxCircleFill : .closeCircleFill)
                                    .iconMedium()
                                    .foregroundStyle(requirement.isEligible ? .secondaryMain : .errorMain)
                                Text(requirement.text)
                                    .subtitle6()
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                    }
                }
                Spacer()
                if isUserVoteChecking {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Group {
                        if userManager.registerZkProof == nil {
                            AppButton(text: "Verification", action: onVerification)
                        } else if isVoted {
                            AppButton(text: "Already voted", action: {})
                                .disabled(true)
                        } else {
                            AppButton(text: "Let's start", action: { isQuestionsShown = true })
                                .disabled(isSubmitting || !isAdmittedToVote || poll.status == .ended || poll.status == .waiting)
                        }
                    }
                    .controlSize(.large)
                }
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
                let nullifier = try userManager.generateNullifierForEvent(poll.eventId.serialize().fullHex)
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
    ZStack {}
        .dynamicSheet(isPresented: .constant(true), fullScreen: true) {
            PollView(poll: ACTIVE_POLLS[0], onClose: {}, onVerification: {})
                .environmentObject(PollsViewModel())
                .environmentObject(UserManager())
                .environmentObject(PassportManager())
                .environmentObject(DecentralizedAuthManager())
        }
}
