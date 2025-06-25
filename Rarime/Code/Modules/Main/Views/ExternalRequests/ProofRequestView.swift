import SwiftUI
import WrappingHStack

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

    private var selector: QueryProofSelector? {
        if let selectorValue = proofParamsResponse?.data.attributes.selector {
            return QueryProofSelector(decimalString: selectorValue)
        } else {
            return nil
        }
    }

    var body: some View {
        ZStack {
            if proofParamsResponse == nil {
                ProgressView()
                    .padding(.vertical, 200)
            } else {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Criteria")
                            .overline2()
                            .foregroundStyle(.textSecondary)
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

                    HorizontalDivider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Requestor")
                            .overline2()
                            .foregroundStyle(.textSecondary)
                        makeItemRow(
                            title: String(localized: "ID"),
                            value: StringUtils.cropMiddle(proofParamsResponse!.data.id)
                        )
                        makeItemRow(
                            title: String(localized: "Host"),
                            value: URL(string: proofParamsResponse!.data.attributes.callbackURL)?.host() ?? "–"
                        )
                    }

                    if let selector {
                        HorizontalDivider()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Revealed data")
                                .overline2()
                                .foregroundStyle(.textSecondary)

                            WrappingHStack(selector.enabledFields, spacing: .constant(4)) { field in
                                Text(field.displayName)
                                    .subtitle6()
                                    .foregroundStyle(.textPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.bgComponentPrimary, in: Capsule())
                                    .padding(.vertical, 2)
                            }
                        }
                    }

                    VStack(spacing: 4) {
                        AppButton(
                            text: isSubmitting ? "Generating..." : "Generate Proof",
                            action: generateProof
                        )
                        .disabled(isSubmitting)
                        .controlSize(.large)
                        AppButton(
                            variant: .quartenary,
                            text: "Cancel",
                            action: onDismiss
                        )
                        .disabled(isSubmitting)
                        .controlSize(.large)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .task { await loadProofParams() }
    }

    private func makeItemRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .body4()
            Spacer()
            Text(value)
                .subtitle6()
                .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(.textPrimary)
    }

    @MainActor
    private func loadProofParams() async {
        do {
            proofParamsResponse = try await VerificatorApi.getExternalRequestParams(url: proofParamsUrl)
        } catch {
            AlertManager.shared.emitError("Failed to load proof params")
            LoggerUtil.common.error("Failed to load proof params: \(error, privacy: .public)")
            onDismiss()
        }
    }

    private func generateProof() {
        Task { @MainActor in
            isSubmitting = true
            defer { isSubmitting = false }

            do {
                guard let passport = passportManager.passport else { throw PassportManagerError.passportNotFound }

                let proof = try await userManager.generateQueryProof(
                    passport: passport,
                    params: proofParamsResponse!.data.attributes
                )

                let response = try await VerificatorApi.sendProof(
                    url: URL(string: proofParamsResponse!.data.attributes.callbackURL)!,
                    userId: proofParamsResponse!.data.id,
                    proof: proof
                )

                if response.data.attributes.status == .uniquenessCheckFailed {
                    AlertManager.shared.emitError("Uniqueness check failed")
                    onDismiss()
                    return
                }

                if response.data.attributes.status != .verified {
                    throw VerificatorApiError.proofStatusNotVerified
                }

                AlertManager.shared.emitSuccess("Proof generated successfully")
                onSuccess()
            } catch {
                AlertManager.shared.emitError("Failed to generate proof")
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
                proofParamsUrl: URL(string: "https://api.orgs.app.stage.rarime.com/integrations/verificator-svc/public/proof-params/0x69d9c5f9dd91dbaff7815947e58dade0db8c8d89e1223259399de86bfc9abd")!,
                onSuccess: {},
                onDismiss: {}
            )
            .environmentObject(UserManager())
        }
}
