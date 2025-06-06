import SwiftUI

protocol NavTab {
    var title: String { get }
}

private enum PollsTab: CaseIterable, NavTab {
    case active, history
    
    var title: String {
        switch self {
        case .active: String(localized: "Active")
        case .history: String(localized: "Finished")
        }
    }
}

struct PollsView: View {
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject var mainViewModel: MainView.ViewModel
    @EnvironmentObject var pollsViewModel: PollsViewModel
    
    let onClose: () -> Void

    var animation: Namespace.ID
    
    @State private var currentTab = PollsTab.active
    @State private var isPollSheetShown = false
    
    @State private var isPollsLoading = true
    
    private var aсtivePolls: [Poll] {
        pollsViewModel.polls.filter { poll in
            poll.status == .waiting || poll.status == .started
        }
    }
    
    private var endedPolls: [Poll] {
        pollsViewModel.polls.filter { poll in
            poll.status == .ended
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            PullToCloseWrapperView(action: onClose) {
                GlassBottomSheet(
                    minHeight: 390,
                    maxHeight: 730,
                    maxBlur: 20,
                    background: {
                        Image(.freedomtoolBg)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                            .ignoresSafeArea()
                    }
                ) {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Freedomtool")
                                    .h1()
                                    .foregroundStyle(.invertedDark)
                                Text("Voting")
                                    .additional1()
                                    .foregroundStyle(Gradients.darkGreenText)
                            }
                            Text("Cast secure, anonymous votes from anywhere, just using your passport")
                                .body3()
                                .foregroundStyle(.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            HStack(alignment: .center, spacing: 16) {
                                AppButton(
                                    variant: .secondary,
                                    text: "Create a poll",
                                    action: {
                                        guard let url = URL(string: ConfigManager.shared.api.votingWebsiteURL.absoluteString) else { return }
                                        openURL(url)
                                    }
                                )
                                .controlSize(.large)
                                AppButton(
                                    variant: .primary,
                                    text: "Scan a QR",
                                    leftIcon: .qrScan2Line,
                                    action: { mainViewModel.isQrCodeScanSheetShown = true }
                                )
                                .controlSize(.large)
                            }
                            HorizontalDivider()
                            HStack(alignment: .center, spacing: 8) {
                                ForEach(PollsTab.allCases, id: \.self) { tab in
                                    Button(action: {
                                        withAnimation {
                                            currentTab = tab
                                        }
                                    }) {
                                        Text(tab == .active
                                            ? "\(aсtivePolls.count) \(tab.title)"
                                            : "\(endedPolls.count) \(tab.title)"
                                        )
                                        .overline2()
                                        .foregroundStyle(currentTab == tab ? .textPrimary : .textSecondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(currentTab == tab ? .bgComponentPrimary : .clear, in: Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        Group {
                            switch currentTab {
                            case .active:
                                makePollsList(aсtivePolls)
                            case .history:
                                makePollsList(endedPolls)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            Button(action: onClose) {
                Image(.closeFill)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(10)
                    .background(.bgComponentPrimary, in: Circle())
            }
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.bgBlur)
        .dynamicSheet(isPresented: $isPollSheetShown, fullScreen: true, bgColor: .additionalGreen) {
            if let selectedPoll = pollsViewModel.selectedPoll {
                PollView(
                    poll: selectedPoll,
                    onClose: { isPollSheetShown = false },
                    onVerification: {
                        isPollSheetShown = false
                        onClose()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            mainViewModel.selectedTab = .identity
                        }
                    }
                )
                .environmentObject(pollsViewModel)
            }
        }
        .task { await loadPolls() }
        .onReceive(pollsViewModel.$votingPollsIds) { _ in
            Task { await loadPolls() }
        }
    }
    
    private func makePollsList(_ polls: [Poll]) -> some View {
        ZStack {
            if isPollsLoading {
                ProgressView()
                    .controlSize(.large)
                    .tint(.textSecondary)
                    .frame(height: 240, alignment: .center)
            } else if !isPollsLoading && polls.isEmpty {
                Text("No polls yet")
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .frame(height: 240, alignment: .center)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(polls) { poll in
                            PollListCard(poll: poll, onViewPoll: {
                                pollsViewModel.selectedPoll = poll
                                isPollSheetShown = true
                            })
                        }
                    }
                    .padding(.top, 12)
                }
            }
        }
    }
    
    @MainActor
    private func loadPolls() async {
        defer { isPollsLoading = false }
        do {
            try await pollsViewModel.loadPollsByIds(AppUserDefaults.shared.votedPollsIds)
        } catch {
            LoggerUtil.common.error("failed to pull polls: \(error, privacy: .public)")
        }
    }
}

private struct PollListCard: View {
    @EnvironmentObject var pollsViewModel: PollsViewModel
    
    let poll: Poll
    
    let onViewPoll: () -> Void
    
    @State private var selectedIndex = 0
    
    private var totalParticipants: Int {
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
    private var questionResults: [QuestionResult] {
        var results: [QuestionResult] = []
        for (question, result) in zip(poll.questions, poll.proposalResults) {
            results.append(
                QuestionResult(
                    question: question.title,
                    options: question.variants.enumerated().map { index, answer in
                        QuestionResultOption(
                            answer: answer,
                            votes: Int(result[index])
                        )
                    }
                )
            )
        }
        return results
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
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
                HorizontalDivider()
            }
            .padding([.top, .horizontal], 16)
            Group {
                HeightPreservingTabView(selection: $selectedIndex) {
                    ForEach(questionResults.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 16) {
                            let totalVotes = questionResults[index].options.map(\.votes).reduce(0, +)
                            Text(questionResults[index].question)
                                .subtitle6()
                                .foregroundStyle(.textPrimary)
                            BarChartPollView(
                                result: questionResults[index],
                                totalVotes: totalVotes
                            )
                        }
                        .padding(.horizontal, 16)
                        .tag(index)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: TabViewHeightPreferenceKey<Int>.self,
                                    value: [index: geometry.size.height]
                                )
                            }
                        )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.default, value: selectedIndex)
                if poll.questions.count > 1 {
                    HorizontalStepIndicator(
                        steps: questionResults.count,
                        currentStep: selectedIndex
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.bottom, 16)
        }
        .onTapGesture(perform: onViewPoll)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.bgPrimary)
        }
    }
}

#Preview {
    PollsView(onClose: {}, animation: Namespace().wrappedValue)
        .environmentObject(PollsViewModel())
        .environmentObject(UserManager())
        .environmentObject(PassportManager())
        .environmentObject(DecentralizedAuthManager())
}
