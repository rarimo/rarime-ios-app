import SwiftUI

struct PassportRevocationView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(Icons.alertLine)
                .square(44)
                .foregroundColor(.warningMain)
                .padding(22)
                .background(.warningLight, in: Circle())
            VStack(spacing: 8) {
                Text("Passport is already registered")
                    .h4()
                    .foregroundStyle(.textPrimary)
                Text("Please, scan your passport one more time to revoke your previous registration")
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            AppButton(text: "Scan passport") {
                NFCScanner.scanPassport(
                    passportViewModel.mrzKey ?? AppUserDefaults.shared.lastMRZKey,
                    passportViewModel.revocationChallenge,
                    false,
                    onCompletion: { result in
                        switch result {
                        case .success(let passport):
                            passportViewModel.revocationPassportPublisher.send(passport)
                            passportViewModel.isUserRevoking = false
                        case .failure(let error):
                            LoggerUtil.common.error("failed to read passport data: \(error.localizedDescription, privacy: .public)")

                            passportViewModel.revocationPassportPublisher.send(completion: .failure(error))

                            passportViewModel.isUserRevoking = false
                        }
                    }
                )
            }
            .controlSize(.large)
        }
        .padding(20)
    }
}

#Preview {
    PassportRevocationView()
        .environmentObject(PassportViewModel())
}
