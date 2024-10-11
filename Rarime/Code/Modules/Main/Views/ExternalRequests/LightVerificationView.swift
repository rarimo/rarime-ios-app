import Identity
import SwiftUI

struct LightVerificationView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var decenralizedAuthManager: DecentralizedAuthManager

    let verificationParamsUrl: URL
    let onSuccess: () -> Void
    let onDismiss: () -> Void

    @State private var verificationParamsResponse: GetProofParamsResponse? = nil
    @State private var isSubmitting = false

    private var citizenship: String {
        guard let mask = verificationParamsResponse?.data.attributes.citizenshipMask else { return "" }
        return String(data: Data(hex: mask), encoding: .utf8) ?? ""
    }

    private var birthDate: Date? {
        guard let birthDateUpperBound = verificationParamsResponse?.data.attributes.birthDateUpperBound else { return nil }
        let birthDateString = String(data: Data(hex: birthDateUpperBound), encoding: .utf8) ?? ""
        return DateUtil.passportDateFormatter.date(from: birthDateString)
    }

    private var minAge: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    var body: some View {
        ZStack {
            if verificationParamsResponse == nil {
                ProgressView()
                    .padding(.vertical, 100)
            } else {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        makeItemRow(
                            title: String(localized: "ID"),
                            value: StringUtils.cropMiddle(verificationParamsResponse!.data.id)
                        )
                        if minAge != nil {
                            makeItemRow(
                                title: String(localized: "Age"),
                                value: "\(minAge!)+"
                            )
                        }
                        if !citizenship.isEmpty {
                            makeItemRow(
                                title: String(localized: "Nationality"),
                                value: Country.fromISOCode(citizenship).flag
                            )
                        }
                    }
                    VStack(spacing: 4) {
                        AppButton(
                            text: isSubmitting ? "Verification..." : "Verify",
                            action: createSignature
                        )
                        .disabled(isSubmitting)
                        .controlSize(.large)
                        AppButton(
                            variant: .tertiary,
                            text: "Cancel",
                            action: onDismiss
                        )
                        .disabled(isSubmitting)
                        .controlSize(.large)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .onAppear {
            Task { @MainActor in
                await loadVerificationParams()
            }
        }
    }

    private func makeItemRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .body3()
            Spacer()
            Text(value)
                .subtitle4()
                .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(.textPrimary)
    }

    private func loadVerificationParams() async {
        do {
            verificationParamsResponse = try await VerificatorApi.getExternalRequestParams(url: verificationParamsUrl)
        } catch {
            AlertManager.shared.emitError(.unknown("Failed to load verification params"))
            LoggerUtil.common.error("Failed to load verification params: \(error, privacy: .public)")
            onDismiss()
        }
    }
    
    private func createSignature() {
        Task { @MainActor in
            isSubmitting = true
            defer { isSubmitting = false }
            
            do {
                guard let passport = passportManager.passport else { throw "failed to get passport" }
                
                if Int(passport.ageString)! < minAge ?? 0 {
                    AlertManager.shared.emitError(.unknown("Your age does not meet the requirements"))
                    onDismiss()
                    return
                }
                
                if !citizenship.isEmpty && passport.nationality != citizenship {
                    AlertManager.shared.emitError(.unknown("Your citizenship does not meet the requirements"))
                    onDismiss()
                    return
                }
                                
                let pubSignals = try userManager.collectPubSignals(
                    passport: passport,
                    params: verificationParamsResponse!.data.attributes
                )
                
                let pubSignalsJSON = try? JSONEncoder().encode(pubSignals)
                
                var error: NSError? = nil
                let signedPubSignals = IdentitySignPubSignalsWithSecp256k1(
                    ConfigManager.shared.api.lightSignaturePrivateKey,
                    pubSignalsJSON,
                    &error
                )
                
                if let error { throw error.localizedDescription }
                
                let response = try await VerificatorApi.sendSignature(
                    url: URL(string: verificationParamsResponse!.data.attributes.callbackURL)!,
                    userId: verificationParamsResponse!.data.id,
                    signature: signedPubSignals,
                    pubSignals: pubSignals
                )
                
                if response.data.attributes.status != .verified {
                    throw "Proof status is not verified"
                }
                
                AlertManager.shared.emitSuccess("The verification is successful")
                onSuccess()
            } catch {
                AlertManager.shared.emitError(.unknown("Failed to submit verification"))
                LoggerUtil.common.error("Failed to submit verification: \(error, privacy: .public)")
                onDismiss()
            }
        }
    }
}

#Preview {
    ZStack {}
        .dynamicSheet(isPresented: .constant(true), title: "Light Verification") {
            LightVerificationView(
                verificationParamsUrl: URL(string: "https://api.orgs.app.stage.rarime.com/integrations/verificator-svc/light/public/proof-params/0x01aca1d0b12a7518606202543cef19c5ecad88f9187bc9365eca51e76f465388")!,
                onSuccess: {},
                onDismiss: {}
            )
            .environmentObject(UserManager())
            .environmentObject(DecentralizedAuthManager())
        }
}
