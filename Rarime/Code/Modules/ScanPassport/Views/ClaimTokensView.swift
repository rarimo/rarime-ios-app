import SwiftUI

struct ClaimTokensView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    
    let showTerms: Bool
    let passport: Passport?
    let onFinish: (Bool) -> Void
    let onClose: () -> Void

    @State private var isClaiming: Bool
    @State private var termsChecked: Bool
    
    init(
        showTerms: Bool = false,
        passport: Passport?,
        onFinish: @escaping (Bool) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.showTerms = showTerms
        self.passport = passport
        self.onFinish = onFinish
        self.onClose = onClose
        
        self.isClaiming = false
        self.termsChecked = !showTerms
    }

    private func claimTokens() async {
        defer { isClaiming = false }
        do {
            isClaiming = true
            
            guard let passport = passport else { throw "failed to get passport" }
            guard let registerZkProof = userManager.registerZkProof else { throw "failed to get registerZkProof" }
            
            let queryZkProof = try await userManager.generateAirdropQueryProof(
                registerZkProof,
                passport
            )
            
            try await userManager.airdrop(queryZkProof)
            try await walletManager.claimAirdrop()
            
            let balance = try await userManager.fetchBalanse()
            userManager.balance = Double(balance) ?? 0
            
            FeedbackGenerator.shared.notify(.success)
            onFinish(true)
        } catch {
            LoggerUtil.passport.error("Error while claiming tokens: \(error.localizedDescription, privacy: .public)")
            
            FeedbackGenerator.shared.notify(.error)
            
            onFinish(false)
            
            AlertManager.shared.emitError(.serviceDown(nil))
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                VStack(spacing: 32) {
                    HStack(spacing: -32) {
                        Image(Icons.rarimo)
                            .iconLarge()
                            .padding(20)
                            .background(.backgroundPure)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.backgroundPrimary, lineWidth: 2))
                        Text(String("🇺🇦"))
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
                        Text("This airdrop is part of a humanitarian effort to help direct funds towards Ukraine.")
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
            if !isClaiming {
                Button(action: onClose) {
                    Image(Icons.close)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                }
            }
        }
    }

    private var footerView: some View {
        VStack(spacing: 16) {
            if showTerms {
                AirdropCheckboxView(checked: $termsChecked)
            }
            AppButton(
                text: isClaiming ? "Claiming..." : "Claim",
                action: {
                    Task {
                        await claimTokens()
                    }
                }
            )
            .disabled(isClaiming || !termsChecked)
            .controlSize(.large)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(.backgroundPure)
    }
}

#Preview {
    ClaimTokensView(showTerms: true, passport: nil, onFinish: { _ in }, onClose: {})
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
}
