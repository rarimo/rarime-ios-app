import SwiftUI

private struct PollRequirement: Identifiable {
    let id = UUID()
    let text: String
    let isEligible: Bool
}

struct PollView: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var passportManager: PassportManager
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager

    let poll: Poll
    let onClose: () -> Void
    
    @State private var isSubmitting = false
    @State private var isQuestionsShown = false

    @State private var isVoted = false
    @State private var isVotedSuccesfully = false
    
    private var formattedCountries: [Country] {
        pollsViewModel.decodedVotingData?.citizenshipMask.map {
            Country.fromISOCode($0.asciiValue)
        } ?? []
    }
    
    private var formattedMinAge: String {
        pollsViewModel.decodedVotingData?.birthDateUpperbound.asciiValue ?? ""
    }
    
    private var pollRequirements: [PollRequirement] {
        let countries = formattedCountries.map { $0.name }.joined(separator: ", ")
        
        let rawMinAgeDate = (try? DateUtil.parsePassportDate(formattedMinAge)) ?? Date()
        let userDOB = (try? DateUtil.parsePassportDate(passportManager.passport?.dateOfBirth ?? "")) ?? Date()
        let age = Calendar.current.dateComponents([.year], from: rawMinAgeDate, to: Date()).year ?? 0
        
        let isAgeEligible = userDOB <= rawMinAgeDate
        
        let isNationalityEligible = {
            guard let nationality = passportManager.passport?.nationality, !formattedCountries.isEmpty else { return false }
            return formattedCountries.contains(Country.fromISOCode(nationality))
        }()
        
        return [
            PollRequirement(
                text: String(localized: "Citizen of \(countries)"),
                isEligible: isNationalityEligible
            ),
            PollRequirement(
                text: String(localized: "Over \(age)+"),
                isEligible: isAgeEligible
            ),
        ]
    }
    
    private var isAdmittedToVote: Bool {
        pollRequirements.allSatisfy { $0.isEligible }
    }
    
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
                    ForEach(pollRequirements, id: \.id) { requirement in
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
        }
        .padding([.top, .horizontal], 20)
        .onAppear(perform: checkIfUserVoted)
    }
    
    private func checkIfUserVoted() {
        Task { @MainActor in
            do {
                let nullifier = try userManager.generateNullifierForEvent(poll.eventId.toHex())
//                TODO: Fix me
//                isVoted = try await pollsViewModel.checkIfUserVoted(nullifier)
            } catch {
                LoggerUtil.common.error("Can't check if user voted: \(error, privacy: .public)")
                AlertManager.shared.emitError(.unknown("Can't check if user voted"))
            }
        }
    }
}

#Preview {
    PollView(poll: ACTIVE_POLLS[0], onClose: {})
        .environmentObject(PollsViewModel())
        .environmentObject(UserManager())
        .environmentObject(PassportManager())
        .environmentObject(DecentralizedAuthManager())
}
