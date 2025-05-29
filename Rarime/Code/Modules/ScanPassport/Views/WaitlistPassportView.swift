import Alamofire
import Identity
import MessageUI
import SwiftUI

struct WaitlistPassportView: View {
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject var passportManager: PassportManager
    @EnvironmentObject var userManager: UserManager

    let onNext: () -> Void
    let onCancel: () -> Void

    @State private var isChecked = false
    @State private var isSending = false
    @State private var isExporting = false
    @State private var isCopied = false
    @State private var isBalanceLoading = false
    @State private var isJoined = false
    
    @State private var cancelables: [Task<Void, Never>] = []

    var country: Country {
        passportManager.passportCountry
    }
    
    var serializedPassport: Data {
        return (try? passportManager.passport?.serialize()) ?? Data()
    }
    
    var isEligibleForReward: Bool {
        !UNSUPPORTED_REWARD_COUNTRIES.contains(country)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppIconButton(icon: Icons.closeFill, action: onCancel)
                .padding([.top, .trailing], 20)
            VStack(spacing: 28) {
                Text(country.flag)
                    .h2()
                    .frame(width: 88, height: 88)
                    .background(.bgComponentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                VStack(spacing: 8) {
                    Text("Waitlist passport")
                        .h3()
                        .foregroundStyle(.textPrimary)
                    Text(country.name)
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                VStack(alignment: .leading, spacing: 24) {
                    Text("Become an ambassador")
                        .h4()
                    Text("If you would like to enroll your country in the early phase, we will need your consent to share some data. Enrolling your country’s passports will entitle you to additional rewards")
                        .body4()
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(alignment: .top, spacing: 12) {
                        AppCheckbox(checked: $isChecked)
                        Text("By checking this box, you are agreeing to share the data groups of the passport and the government signature")
                            .body5()
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.textSecondary)
                    }
                }
                .foregroundStyle(.textPrimary)
                Spacer()
                VStack(spacing: 8) {
                    AppButton(
                        text: "Join the program",
                        rightIcon: Icons.arrowRight,
                        action: {
                            Task { @MainActor in
                                await joinRewardsProgram()
                                if isChecked {
                                    isSending = true
                                } else {
                                    onNext()
                                }
                            }
                        }
                    )
                    .controlSize(.large)
                    .disabled(isJoined || isSending || isBalanceLoading)
                    AppButton(
                        variant: .quartenary,
                        text: "Cancel",
                        action: onCancel
                    )
                    .controlSize(.large)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 140)
        }
        .onAppear(perform: checkIfUserJoined)
        .onDisappear(perform: cleanup)
        .onChange(of: isSending) { isSending in
            if !isSending {
                onNext()
            }
        }
        .dynamicSheet(isPresented: $isSending, fullScreen: true) {
            if MFMailComposeViewController.canSendMail() {
                MailView(
                    subject: "Passport from: \(UIDevice.modelName)",
                    attachment: (try? passportManager.passport?.serialize()) ?? Data(),
                    fileName: "passport.json",
                    isShowing: $isSending,
                    result: .constant(nil)
                )
            } else {
                savePassportDataView
            }
        }
    }
    
    var savePassportDataView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(spacing: 16) {
                Image(Icons.identificationCard)
                    .square(44)
                    .frame(width: 88, height: 88)
                    .background(.bgComponentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                Text("Save your passport data")
                    .h4()
                    .foregroundStyle(.textPrimary)
                Text("Your passport data will be saved on your device. You can share it with us to expedite the support of your passport.")
                    .body4()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320)
                    .foregroundStyle(.textSecondary)
                HorizontalDivider()
                VStack(alignment: .leading, spacing: 16) {
                    Text("HOW TO SHARE")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("1. Save passport data on your device")
                        .body4()
                        .foregroundStyle(.textPrimary)
                    Text("2. Send the saved file to the email address below")
                        .body4()
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: 8) {
                        Text(ConfigManager.shared.feedback.feedbackEmail)
                            .body3()
                            .foregroundStyle(.textPrimary)
                        Image(isCopied ? Icons.check : Icons.copySimple).iconMedium()
                    }
                    .onTapGesture {
                        if isCopied { return }
                        UIPasteboard.general.string = ConfigManager.shared.feedback.feedbackEmail
                        isCopied = true
                        FeedbackGenerator.shared.impact(.medium)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isCopied = false
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.bgComponentPrimary)
                    .foregroundStyle(.textPrimary)
                    .cornerRadius(8)
                    Text("3. When we support your country, you will be notified in the app")
                        .body4()
                        .foregroundStyle(.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            AppButton(
                text: "Save to files",
                rightIcon: Icons.arrowRight,
                action: { isExporting = true }
            )
            .controlSize(.large)
            .fileExporter(
                isPresented: $isExporting,
                document: JSONDocument(serializedPassport),
                contentType: .json,
                defaultFilename: "passport.json"
            ) { result in
                switch result {
                case .success:
                    LoggerUtil.common.info("Passport data saved")
                    onNext()
                case .failure(let error):
                    LoggerUtil.common.error("Failed to save passport data: \(error, privacy: .public)")
                }
            }
        }
        .padding(.top, 80)
        .padding(.bottom, 20)
        .padding(.horizontal, 24)
    }
    
    func joinRewardsProgram() async {
        if !isEligibleForReward {
            return
        }
        
        do {
            guard let user = userManager.user else { throw "failed to get user" }
                
            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
                
            let country = passportManager.passport?.nationality ?? ""
                
            let dg1 = passportManager.passport?.dg1 ?? Data()
            
            var calculateAnonymousIDError: NSError?
            let anonymousID = IdentityCalculateAnonymousID(dg1, Points.PointsEventId, &calculateAnonymousIDError)
            if let calculateAnonymousIDError {
                throw calculateAnonymousIDError
            }
                
            var error: NSError?
            let hmacMessage = IdentityCalculateHmacMessage(accessJwt.payload.sub, country, anonymousID, &error)
            if let error {
                throw error
            }
                
            let key = Data(hex: ConfigManager.shared.api.joinRewardsKey) ?? Data()
                
            let hmacSingature = HMACUtils.hmacSha256(hmacMessage ?? Data(), key)
                
            let points = Points(ConfigManager.shared.api.pointsServiceURL)
            let _ = try await points.joinRewardsProgram(
                accessJwt,
                country,
                hmacSingature.hex,
                anonymousID?.hex ?? ""
            )
                
            LoggerUtil.common.info("User joined program")
        } catch {
            LoggerUtil.common.error("failed to join rewards program: \(error, privacy: .public)")
        }
    }
    
    func checkIfUserJoined() {
        isBalanceLoading = true

        let cancelable = Task { @MainActor in
            defer { self.isBalanceLoading = false }
            do {
                guard let user = userManager.user else { throw "failed to get user" }
                let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)

                let pointsBalance = try await userManager.fetchPointsBalance(accessJwt)
                isJoined = pointsBalance.isVerified
            } catch let afError as AFError where afError.isExplicitlyCancelledError {
                return
            } catch {
                LoggerUtil.common.error("failed to fetch balance: \(error.localizedDescription, privacy: .public)")
            }
        }

        cancelables.append(cancelable)
    }
    
    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
}

#Preview {
    WaitlistPassportView(onNext: {}, onCancel: {})
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
        .environmentObject(DecentralizedAuthManager())
}
