import SwiftUI

struct ProofRequestView: View {
    let proofParamsUrl: URL
    let onSuccess: () -> Void
    let onDismiss: () -> Void

    @State private var isLoading = false
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                makeItemRow(title: "Proof Params URL", value: proofParamsUrl.absoluteString)
            }
            VStack(spacing: 4) {
                AppButton(text: "Generate Proof", action: generateProof)
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
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
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

    private func generateProof() {
        Task { @MainActor in
            isSubmitting = true
            defer { isSubmitting = false }

            do {
                // TODO: Generate proof
                try await Task.sleep(nanoseconds: 3_000_000_000)
                AlertManager.shared.emitSuccess("Proof generated successfully")
                onSuccess()
            } catch {
                AlertManager.shared.emitError(.unknown("Failed to generate proof"))
                LoggerUtil.common.error("Failed to generate proof: \(error, privacy: .public)")
            }
        }
    }
}

#Preview {
    ZStack {}
        .dynamicSheet(isPresented: .constant(true), title: "Proof Request") {
            ProofRequestView(
                proofParamsUrl: URL(string: "https://example.com")!,
                onSuccess: {},
                onDismiss: {}
            )
        }
}
