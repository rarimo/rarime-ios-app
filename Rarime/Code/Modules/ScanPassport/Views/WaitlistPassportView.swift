import Identity
import SwiftUI

struct WaitlistPassportView: View {
    @EnvironmentObject var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject var passportViewModel: PassportViewModel
    @EnvironmentObject var userManager: UserManager

    let onNext: () -> Void
    let onCancel: () -> Void

    @State private var isSending = false

    var country: Country {
        passportViewModel.passportCountry
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
                InfoAlert(text: "Information shared includes the data groups of the passport and the government signature") {}
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
                    joinRewardsProgram()
                    isSending = true
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
            MailView(
                subject: "Passport from: \(UIDevice.modelName)",
                attachment: (try? passportViewModel.passport?.serialize()) ?? Data(),
                fileName: "passport.json",
                isShowing: $isSending,
                result: .constant(nil)
            )
        }
    }
    
    func joinRewardsProgram() {
        if !passportViewModel.isEligibleForReward {
            return
        }
        
        Task { @MainActor in
            do {
                guard let user = userManager.user else { throw "failed to get user" }
                
                if decentralizedAuthManager.accessJwt == nil {
                    try await decentralizedAuthManager.initializeJWT(user.secretKey)
                }
                
                try await decentralizedAuthManager.refreshIfNeeded()
                
                guard let accessJwt = decentralizedAuthManager.accessJwt else { throw "accessJwt is nil" }
                
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
    }
}

#Preview {
    WaitlistPassportView(onNext: {}, onCancel: {})
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
        .environmentObject(DecentralizedAuthManager())
}
