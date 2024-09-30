import SwiftUI

struct ProofRequestView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportManager: PassportManager

    let proofParamsUrl: URL
    let onSuccess: () -> Void
    let onDismiss: () -> Void

    @State private var proofParamsResponse: GetProofParamsResponse? = nil
    @State private var isSubmitting = false

    private var hasUniqueness: Bool {
        Int(proofParamsResponse?.data.attributes.timestampUpperBound ?? "") != 0 && proofParamsResponse?.data.attributes.identityCounterUpperBound != 0
    }

    private var citizenship: String {
        guard let mask = proofParamsResponse?.data.attributes.citizenshipMask else { return "" }
        return String(data: Data(hex: mask), encoding: .utf8) ?? ""
    }

    private var birthDate: Date? {
        guard let birthDateUpperBound = proofParamsResponse?.data.attributes.birthDateUpperBound else { return nil }
        let birthDateString = String(data: Data(hex: birthDateUpperBound), encoding: .utf8) ?? ""
        return DateUtil.passportDateFormatter.date(from: birthDateString)
    }

    private var minAge: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }

    var body: some View {
        ZStack {
            if proofParamsResponse == nil {
                ProgressView()
                    .padding(.vertical, 100)
            } else {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        makeItemRow(
                            title: String(localized: "ID"),
                            value: StringUtils.cropMiddle(proofParamsResponse!.data.id)
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
                        makeItemRow(
                            title: String(localized: "Uniqueness"),
                            value: hasUniqueness ? "Yes" : "No"
                        )
                    }
                    VStack(spacing: 4) {
                        AppButton(
                            text: isSubmitting ? "Generating..." : "Generate Proof",
                            action: generateProof
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
                await loadProofParams()
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

    private func loadProofParams() async {
        do {
            proofParamsResponse = try await VerificatorApi.getExternalRequestParams(url: proofParamsUrl)
        } catch {
            AlertManager.shared.emitError(.unknown("Failed to load proof params"))
            LoggerUtil.common.error("Failed to load proof params: \(error, privacy: .public)")
            onDismiss()
        }
    }

    private func generateProof() {
        Task { @MainActor in
            isSubmitting = true
            defer { isSubmitting = false }

            do {
                guard let passport = passportManager.passport else { throw "failed to get passport" }

                let proof = try await userManager.generateQueryProof(
                    passport: passport,
                    params: proofParamsResponse!.data.attributes
                )
                let response = try await VerificatorApi.sendProof(
                    url: URL(string: proofParamsResponse!.data.attributes.callbackURL)!,
                    userId: proofParamsResponse!.data.id,
                    proof: proof
                )

                if response.data.attributes.status != .verified {
                    throw "Proof status is not verified"
                }

                AlertManager.shared.emitSuccess("Proof generated successfully")
                onSuccess()
            } catch {
                AlertManager.shared.emitError(.unknown("Failed to generate proof"))
                LoggerUtil.common.error("Failed to generate query proof: \(error, privacy: .public)")
                onDismiss()
            }
        }
    }
}

#Preview {
    ZStack {}
        .dynamicSheet(isPresented: .constant(true), title: "Proof Request") {
            ProofRequestView(
                proofParamsUrl: URL(string: "https://api.orgs.app.stage.rarime.com/integrations/verificator-svc/public/proof-params/0x19e8958c2c9cf59d1bab2933754513f5ac20f546c691f51b5b63c07e732dee06")!,
                onSuccess: {},
                onDismiss: {}
            )
            .environmentObject(UserManager())
        }
}
