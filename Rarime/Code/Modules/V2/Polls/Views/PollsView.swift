import SwiftUI

protocol NavTab {
    var title: String { get }
}

private enum PollsTab: CaseIterable, NavTab {
    case active, history
    
    var title: String {
        switch self {
        case .active: String(localized: "Active")
        case .history: String(localized: "History")
        }
    }
}

struct PollsView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject private var externalRequestsManager: ExternalRequestsManager
    @EnvironmentObject var mainViewModel: V2MainView.ViewModel
    
    @StateObject private var pollsViewModel = PollsViewModel()
    
    let onClose: () -> Void

    var animation: Namespace.ID
    
    @State private var currentTab = PollsTab.active
    @State private var isPollsLoading = true
    @State private var earlyPullTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .trailing], 20)
            Image(Images.dotCountry)
                .resizable()
                .scaledToFill()
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
            GlassBottomSheet(minHeight: 330, maxHeight: 730, canOpenSheet: !pollsViewModel.polls.isEmpty) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Freedomtool")
                                .h1()
                                .foregroundStyle(.baseBlack)
                                .matchedGeometryEffect(
                                    id: AnimationNamespaceIds.title,
                                    in: animation,
                                    properties: .position
                                )
                            Text("Voting")
                                .additional1()
                                .foregroundStyle(.baseBlack.opacity(0.4))
                                .matchedGeometryEffect(
                                    id: AnimationNamespaceIds.subtitle,
                                    in: animation,
                                    properties: .position
                                )
                        }
                        Text("An identification and privacy solution that revolutionizes polling, surveying and election processes")
                            .body3()
                            .foregroundStyle(.baseBlack.opacity(0.5))
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment: .center, spacing: 16) {
                            AppIconButton(variant: .secondary, icon: Icons.addFill, cornerRadius: 20, action: {
                                guard let url = URL(string: ConfigManager.shared.api.votingWebsiteURL.absoluteString) else { return }
                                openURL(url)
                            })
                                .controlSize(.large)
                            AppButton(variant: .tertiary, text: "Scan a QR", action: { mainViewModel.isQrCodeScanSheetShown = true })
                                .controlSize(.large)
                        }
                        HorizontalDivider(color: .bgComponentBasePrimary)
                        HStack(alignment: .center, spacing: 8) {
                            ForEach(PollsTab.allCases, id: \.self) { tab in
                                Button(action: { currentTab = tab }) {
                                    Text(tab.title)
                                        .overline2()
                                        .foregroundStyle(currentTab == tab ? .baseBlack : .baseBlack.opacity(0.4))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(currentTab == tab ? Color.bgComponentBasePrimary : Color.clear)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // TODO: rewrite with TabView
                    Group {
                        if currentTab == .active {
                            makePollsList(
                                pollsViewModel.polls.filter { poll in
                                    poll.status == .waiting || poll.status == .started
                                }
                            )
                        } else {
                            makePollsList(
                                pollsViewModel.polls.filter { poll in
                                    poll.status == .ended
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.bottom, 24)
            }
        }
        .background(
            Gradients.gradientFifth
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                .ignoresSafeArea()
        )
        .sheet(item: $pollsViewModel.selectedPoll) { poll in
            PollView(poll: poll, onClose: { pollsViewModel.selectedPoll = nil })
        }
        .environmentObject(pollsViewModel)
        .onAppear {
            self.earlyPullTask = Task { @MainActor in
                defer { isPollsLoading = false }
                do {
                    try await pollsViewModel.loadNewPolls()
                } catch {
                    LoggerUtil.common.error("failed to pull polls: \(error, privacy: .public)")
                }
            }
        }
        .onDisappear {
            earlyPullTask?.cancel()
        }
    }
    
    private func makePollsList(_ polls: [Poll]) -> some View {
        VStack(spacing: 8) {
            ForEach(polls) { poll in
                PollListCard(poll: poll, onViewPoll: {
                    pollsViewModel.selectedPoll = poll
                })
            }
        }
    }
}

private struct PollListCard: View {
    let poll: Poll

    let onViewPoll: () -> Void
    
    var totalParticipants: Int {
        return poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }.max() ?? 0
    }
    
    var body: some View {
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
            HorizontalDivider()
            AppButton(variant: .secondary, text: "View", action: onViewPoll)
        }
        .padding(.all, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.bgPrimary)
        }
    }
}


#Preview {
    PollsView(onClose: {}, animation: Namespace().wrappedValue)
}
