import Alamofire
import SwiftUI

private enum ViewState {
    case intro, about
}

struct RewardsIntroView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    
    var onVerify: () -> Void
    
    @State private var termsChecked = false

    @State private var code = ""
    @State private var codeErrorMessage = ""
    @State private var isVerifyingCode = false
    @State private var viewState: ViewState = .intro
    
    @State private var isLoading = false

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .controlSize(.large)
            } else {
                ZStack {
                    introView.offset(x: viewState == .intro ? 0 : -screenWidth)
                    aboutView.offset(x: viewState == .about ? 0 : screenWidth)
                }
                .animation(.easeInOut, value: viewState)
            }
        }
        .onAppear {
            Task { @MainActor in
                await checkDeferredReferralCode()
            }
        }
    }

    var introView: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Join Rewards Program"),
                description: String(localized: "Receive rewards for using RariMe app"),
                icon: Image(Images.rewardCoin).square(110),
                subheader: {
                    AppTextField(
                        text: $code,
                        errorMessage: $codeErrorMessage,
                        placeholder: "Enter invitation code",
                        action: {
                            Button(action: {
                                Task { @MainActor in
                                    await verifyCode(code)
                                }
                            }) {
                                Image(Icons.arrowRight)
                                    .iconMedium()
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                            }
                            .buttonStyle(AppButtonStyle(variant: .primary))
                            .clipShape(RoundedRectangle(cornerRadius: 1000))
                            .disabled(code.isEmpty || isVerifyingCode)
                        }
                    )
                    .controlSize(.large)
                    .disabled(isVerifyingCode)
                }
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW CAN I GET A CODE?")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("You must be invited or receive a code from social channels")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
                HStack(spacing: 16) {
                    SocialCard(
                        title: "X",
                        icon: Icons.xCircle,
                        url: URL(string: "https://twitter.com/Rarimo_protocol")!
                    )
                    SocialCard(
                        title: "Discord",
                        icon: Icons.discord,
                        url: URL(string: "https://discord.gg/Bzjm5MDXrU")!
                    )
                }
            }
            Button(action: { viewState = .about }) {
                Text("Learn more about the program")
                    .buttonSmall()
                    .foregroundStyle(.textSecondary)
            }
            Spacer()
        }
    }
    
    var excludedCountriesString: String {
        UNSUPPORTED_REWARD_COUNTRIES
            .filter { country in country != .unknown }
            .map { country in country.name }
            .joined(separator: ", ")
    }

    var aboutView: some View {
        ZStack(alignment: .topLeading) {
            Button(action: { viewState = .intro }) {
                Image(Icons.arrowLeft)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
            }
            VStack(spacing: 32) {
                Text("About the reward program")
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Text("RMO tokens will be exclusively distributed via the RariMe app. To claim tokens, create an incognito profile using your biometric passport. Depending on which country issued the passport, you’ll either be able to claim a token right away or be put on a waitlist.\n\nIf you are added to the waitlist it means that you are eligible to claim tokens in the next wave of airdrops. The app will notify you when you are added.\n\nCertain jurisdictions are excluded from the reward program: \(excludedCountriesString)")
                    .body3()
                    .foregroundStyle(.textPrimary)
                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW CAN I GET THE INVITE CODE?")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("The app’s rewards program is invite-only. Get invited by an authorized user or ask a community member for an invite code.")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func checkDeferredReferralCode() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let deferredReferralCode = userManager.user?.deferredReferralCode else { return }
        if deferredReferralCode.isEmpty { return }

        await verifyCode(deferredReferralCode)
    }
    
    private func verifyCode(_ code: String) async {
        isVerifyingCode = true
        defer { isVerifyingCode = false }
            
        let isValidCode = isValidReferalCodeFormat(code)
        if !isValidCode {
            codeErrorMessage = String(localized: "Invalid invitation code")
            return
        }
            
        do {
            guard let user = userManager.user else { throw "user is not initalized" }
            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
                
            let pointsSvc = Points(ConfigManager.shared.api.pointsServiceURL)
            let result = try await pointsSvc.createPointsBalance(
                accessJwt,
                code
            )
                
            if !result.data.attributes.isDisabled {
                userManager.user?.userReferralCode = code
                LoggerUtil.common.info("User verified code: \(code, privacy: .public)")
                    
                onVerify()
                return
            }
                
            codeErrorMessage = String(localized: "Something went wrong")
        } catch {
            do {
                guard let error = error as? AFError else { throw error }
                    
                let openApiHttpCode = try error.retriveOpenApiHttpCode()
                if openApiHttpCode == HTTPStatusCode.notFound.rawValue {
                    codeErrorMessage = String(localized: "Invalid invitation code")
                    return
                }
                    
                throw error
            } catch {
                codeErrorMessage = String(localized: "Failed to verify code, try again later")
                LoggerUtil.common.error("Failed to verify code: \(error, privacy: .public)")
                    
                AlertManager.shared.emitError(Errors.unknown("Failed to verify code, one of services is down"))
            }
        }
    }
}

private struct SocialCard: View {
    let title: String
    let icon: String
    let url: URL

    var body: some View {
        Button(action: { UIApplication.shared.open(url) }) {
            VStack(spacing: 8) {
                Image(icon).square(24)
                Text(title)
                    .buttonSmall()
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

private func isValidReferalCodeFormat(_ string: String) -> Bool {
    let pattern = "^[a-zA-Z0-9]{11}$"
    let regex = try? NSRegularExpression(pattern: pattern)
    let range = NSRange(location: 0, length: string.utf16.count)
    return regex?.firstMatch(in: string, options: [], range: range) != nil
}

#Preview {
    let userManager = UserManager.shared
    
    return RewardsIntroView {}
        .environmentObject(ConfigManager())
        .environmentObject(DecentralizedAuthManager())
        .environmentObject(userManager)
        .onAppear {
            try? userManager.createNewUser()
        }
}
