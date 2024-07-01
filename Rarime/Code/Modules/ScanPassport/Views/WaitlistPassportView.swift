import Identity
import MessageUI
import SwiftUI

struct WaitlistPassportView: View {
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject var passportViewModel: PassportViewModel
    @EnvironmentObject var userManager: UserManager

    let onNext: () -> Void
    let onCancel: () -> Void

    @State private var isChecked = false
    @State private var isSending = false
    @State private var isExporting = false
    @State private var isCopied = false

    var country: Country {
        passportViewModel.passportCountry
    }
    
    var serializedPassport: Data {
        return (try? passportViewModel.passport?.serialize()) ?? Data()
    }

    var body: some View {
        HomeIntroLayout(
            title: String(localized: "Waitlist passport"),
            description: country.name,
            icon: Text(country.flag)
                .h4()
                .frame(width: 72, height: 72)
                .background(.componentPrimary, in: Circle())
                .foregroundStyle(.textPrimary)
        ) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Become an ambassador")
                    .subtitle2()
                Text("If you would like to enroll your country in the early phase, we will need your consent to share some data. Enrolling your country’s passports will entitle you to additional rewards")
                    .body3()
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: 12) {
                    AppCheckbox(checked: $isChecked)
                    Text("By checking this box, you are agreeing to share the data groups of the passport and the government signature")
                        .body4()
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.textSecondary)
                }
            }
            .foregroundStyle(.textPrimary)
        }
        .padding(.top, 24)
        Spacer()
        VStack(spacing: 12) {
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
            AppButton(
                variant: .tertiary,
                text: "Cancel",
                action: onCancel
            )
            .controlSize(.large)
        }
        .padding(.horizontal, 24)
        .onChange(of: isSending) { isSending in
            if !isSending {
                onNext()
            }
        }
        .dynamicSheet(isPresented: $isSending, fullScreen: true) {
            if MFMailComposeViewController.canSendMail() {
                MailView(
                    subject: "Passport from: \(UIDevice.modelName)",
                    attachment: (try? passportViewModel.passport?.serialize()) ?? Data(),
                    fileName: "passport.json",
                    isShowing: $isSending,
                    result: .constant(nil)
                )
            } else {
                savePassportDataView
            }
        }
    }
    
    func joinRewardsProgram() async {
        if !passportViewModel.isEligibleForReward {
            return
        }
        
        do {
            guard let user = userManager.user else { throw "failed to get user" }
                
            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
                
            let country = passportViewModel.passport?.nationality ?? ""
                
            let dg1 = passportViewModel.passport?.dg1 ?? Data()
                
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
            LoggerUtil.common.info("failed to join rewards program: \(error, privacy: .public)")
        }
    }
    
    var savePassportDataView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(spacing: 16) {
                Image(Icons.identificationCard)
                    .iconLarge()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                Text("Save your passport data")
                    .h6()
                    .foregroundStyle(.textPrimary)
                Text("Your passport data will be saved on your device. You can share it with us to expedite the support of your passport.")
                    .body3()
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
                        .body3()
                        .foregroundStyle(.textPrimary)
                    Text("2. Send the saved file to the email address below")
                        .body3()
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: 8) {
                        Text(ConfigManager.shared.feedback.feedbackEmail)
                            .body2()
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
                    .background(.componentPrimary)
                    .foregroundStyle(.textPrimary)
                    .cornerRadius(8)
                    Text("3. When we support your country, you will be notified in the app")
                        .body3()
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
}

#Preview {
    WaitlistPassportView(onNext: {}, onCancel: {})
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
        .environmentObject(DecentralizedAuthManager())
}
