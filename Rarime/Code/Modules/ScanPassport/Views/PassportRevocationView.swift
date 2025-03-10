import SwiftUI

struct PassportRevocationView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(Icons.warning)
                .iconLarge()
                .frame(width: 72, height: 72)
                .background(.warningLighter, in: Circle())
                .foregroundStyle(.warningMain)
            Text("Passport is already registered")
                .h6()
                .foregroundStyle(.textPrimary)
            Text("Please, scan your passport one more time to revoke your previous registration")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            AppButton(text: "Scan passport") {
                NFCScanner.scanPassport(
                    passportViewModel.mrzKey ?? "",
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
