import SwiftUI

struct ReserveTokensButton: View {
    @EnvironmentObject var viewModel: HomeView.ViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var passportManager: PassportManager
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager

    @State private var isReserving = false

    var canReserveTokens: Bool {
        viewModel.pointsBalance != nil &&
            !viewModel.pointsBalance!.isVerified &&
            !passportManager.isUnsupportedForRewards &&
            userManager.registerZkProof != nil &&
            !userManager.isRevoked
    }

    var body: some View {
        if canReserveTokens {
            Button(action: { Task { await reserveTokens() } }) {
                if isReserving {
                    ProgressView()
                        .tint(.successMain)
                        .controlSize(.small)
                } else {
                    Image(.moneyDollarCircleLine)
                        .iconMedium()
                        .foregroundStyle(.successMain)
                }
            }
            .frame(width: 20, height: 20)
            .padding(4)
            .background(.successLight, in: Circle())
        }
    }

    @MainActor
    private func reserveTokens() async {
        isReserving = true
        defer { isReserving = false }

        do {
            guard let user = userManager.user else { throw "failed to get user" }
            guard let passport = passportManager.passport else { throw "passport not found" }

            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
            try await userManager.reserveTokens(accessJwt, passport)

            FeedbackGenerator.shared.notify(.success)
            AlertManager.shared.emitSuccess("Tokens reserved successfully")
        } catch {
            LoggerUtil.common.error("Failed to reserve tokens: \(error, privacy: .public)")
            AlertManager.shared.emitError("Failed to reserve tokens")
        }
    }
}

#Preview {
    ReserveTokensButton()
        .environmentObject(HomeView.ViewModel())
        .environmentObject(UserManager())
        .environmentObject(PassportManager())
}
