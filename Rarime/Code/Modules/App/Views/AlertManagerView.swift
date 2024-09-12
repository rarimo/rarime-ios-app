import SwiftUI

struct AlertManagerView: View {
    @EnvironmentObject private var alertManager: AlertManager

    @State private var alertSubject: AppAlertSubject?
    @State private var timer: Timer?

    private func resetTimer() {
        timer?.invalidate()
        timer = .scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            alertSubject = nil
        }
    }

    var body: some View {
        ZStack {
            if alertSubject != nil {
                AppAlert(type: alertSubject!.type, message: alertSubject!.message)
                    .onTapGesture { alertSubject = nil }
            }
        }
        .animation(.easeOut, value: alertSubject)
        .onReceive(alertManager.subject) { alert in
            self.alertSubject = alert

            if alert.type == .success {
                FeedbackGenerator.shared.notify(.success)
            } else if alert.type == .error {
                FeedbackGenerator.shared.notify(.error)
            }

            resetTimer()
        }
    }
}

private struct PreviewView: View {
    @EnvironmentObject private var alertManager: AlertManager

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 16) {
                AppButton(text: LocalizedStringResource("Emit error", table: "preview")) {
                    alertManager.emitError(Errors.unknown(nil))
                }
                AppButton(text: LocalizedStringResource("Emit success", table: "preview")) {
                    alertManager.emitSuccess("Success")
                }
                AppButton(text: LocalizedStringResource("Emit processing", table: "preview")) {
                    alertManager.emitProcessing("Processing")
                }
            }
            .padding(.top, 120)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            AlertManagerView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .environmentObject(alertManager)
    }
}

#Preview {
    PreviewView()
        .environmentObject(AlertManager())
}
