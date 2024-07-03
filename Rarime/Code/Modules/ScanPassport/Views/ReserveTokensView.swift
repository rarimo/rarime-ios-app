import SwiftUI
import Alamofire

struct ReserveTokensView: View {
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var userManager: UserManager

    let showTerms: Bool
    let passport: Passport?
    let onFinish: (Bool) -> Void
    let onClose: () -> Void

    @State private var isReserving: Bool
    @State private var termsChecked: Bool
    
    @State private var isAlreadyReserved = false
    
    var reverveButtonText: LocalizedStringResource {
        if isAlreadyReserved {
            return "Close"
        } else {
            return isReserving ? "Reserving..." : "Reserve"
        }
    }

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

        self.isReserving = false
        self.termsChecked = !showTerms
    }

    private var passportCountry: Country {
        .fromISOCode(passport?.nationality ?? "")
    }

    private func reserveTokens() async {
        defer { isReserving = false }
        do {
            isReserving = true
            
            guard let user = userManager.user else { throw "failed to get user" }
            
            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
            
            guard let passport else { throw "passport is nil" }
            guard let registerZkProof = userManager.registerZkProof else { throw "registerZkProof is nil" }
            
            try await userManager.reserveTokens(accessJwt, registerZkProof, passport)
            FeedbackGenerator.shared.notify(.success)
            onFinish(true)
        } catch {
            do {
                guard let error = error as? AFError else { throw error }
                
                let openApiHttpCode = try error.retriveOpenApiHttpCode()
                
                if
                    openApiHttpCode == HTTPStatusCode.conflict.rawValue
                        || openApiHttpCode == HTTPStatusCode.tooManyRequests.rawValue
                {
                    isAlreadyReserved = true
                    isReserving = false
                    
                    return
                }
                
                throw error
            } catch {
                LoggerUtil.passport.error("Error while reserving tokens: \(error.localizedDescription, privacy: .public)")
                FeedbackGenerator.shared.notify(.error)
                onFinish(false)
                AlertManager.shared.emitError(.serviceDown(nil))
            }
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
                        Text(passportCountry.flag)
                            .h4()
                            .frame(width: 72, height: 72)
                            .background(.backgroundPure)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.backgroundPrimary, lineWidth: 2))
                    }
                    VStack(spacing: 12) {
                        Text("Reserve \(PASSPORT_RESERVE_TOKENS.formatted()) RMO tokens")
                            .h6()
                            .foregroundStyle(.textPrimary)
                        Text("The passport is in the allowlist")
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
            if !isReserving {
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
                text: reverveButtonText,
                action: {
                    if isAlreadyReserved {
                        onFinish(false)
                        
                        return
                    }
                    
                    Task { await reserveTokens() }
                }
            )
            .disabled(isReserving || !termsChecked)
            .controlSize(.large)
            if isAlreadyReserved {
                Text("You have already reserved tokens")
                    .body3()
                    .foregroundStyle(.red)
                    .opacity(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(.backgroundPure)
    }
}

#Preview {
    ReserveTokensView(showTerms: true, passport: nil, onFinish: { _ in }, onClose: {})
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(DecentralizedAuthManager())
}
