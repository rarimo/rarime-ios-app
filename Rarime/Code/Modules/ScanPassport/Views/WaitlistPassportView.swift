import SwiftUI
import Identity

struct WaitlistPassportView: View {
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
                action: { isSending = true }
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
        .onAppear(perform: joinRewardsProgram)
    }
    
    func joinRewardsProgram() {
        Task { @MainActor in
            do {
                let country = passportViewModel.passport?.nationality ?? ""
                
                var nullifier = try userManager.generateNullifierForEvent(Points.PointsEventId)
                
                var error: NSError?
                let hmacMessage = IdentityCalculateHmacMessage(nullifier, country, &error)
                if let error {
                    throw error
                }
                
                let hmacSingature = HMACUtils.hmacSha256(hmacMessage ?? Data(), ConfigManager.shared.api.joinRewardsKey.data(using: .utf8) ?? Data())
                
                let points = Points(ConfigManager.shared.api.pointsServiceURL)
                let _ = try await points.joinRewardsProgram(
                    country,
                    nullifier,
                    hmacSingature.hex
                )
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
}
