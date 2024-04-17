import SwiftUI

struct ClaimTokensView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel
    let onFinish: () -> Void

    private func claimTokens() async {
        do {
            try await passportViewModel.claimTokens()
            FeedbackGenerator.shared.notify(.success)
            onFinish()
        } catch { /* empty */ }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 32) {
                HStack(spacing: -32) {
                    Image(Icons.rarimo)
                        .iconLarge()
                        .padding(20)
                        .background(.backgroundPure)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.backgroundPrimary, lineWidth: 2))
                    Text("🇺🇦")
                        .h4()
                        .frame(width: 72, height: 72)
                        .background(.backgroundPure)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.backgroundPrimary, lineWidth: 2))
                }
                VStack(spacing: 12) {
                    Text("Claim \(RARIMO_AIRDROP_REWARD) RMO tokens")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, ")
                        .body3()
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            footerView
        }
        .padding(.top, 80)
        .background(.backgroundPrimary)
    }

    private var footerView: some View {
        VStack(spacing: 16) {
            HorizontalDivider()
            AppButton(
                text: passportViewModel.isClaiming ? "Claiming..." : "Claim",
                action: {
                    Task {
                        await claimTokens()
                    }
                }
            )
            .disabled(passportViewModel.isClaiming)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    ClaimTokensView(onFinish: {})
        .environmentObject(PassportViewModel())
}
