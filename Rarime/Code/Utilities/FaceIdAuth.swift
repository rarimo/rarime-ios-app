import Foundation
import LocalAuthentication

class FaceIdAuth {
    static let shared = FaceIdAuth()

    func authenticate(
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void,
        onNotAvailable: @escaping () -> Void
    ) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Enable Face ID Authentication"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success {
                    onSuccess()
                } else {
                    onFailure()
                }
            }
        } else {
            onNotAvailable()
        }
    }
}
