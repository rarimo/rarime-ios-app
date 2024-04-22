import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    let privacyPolicyURL: URL
    let termsOfUseURL: URL
    let version: String

    init() {
        do {
            guard
                let privacyPolicyURLRaw = Bundle.main.object(forInfoDictionaryKey: "PRIVACY_POLICY_URL") as? String,
                let termsOfUseURLRaw = Bundle.main.object(forInfoDictionaryKey: "TERMS_OF_USE_URL") as? String,
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            else {
                throw "some config value aren't initialized"
            }

            guard
                let privacyPolicyURL = URL(string: String(privacyPolicyURLRaw.dropFirst().dropLast())),
                let termsOfUseURL = URL(string: String(termsOfUseURLRaw.dropFirst().dropLast()))
            else {
                throw "PRIVACY_POLICY_URL and/or TERMS_OF_USE_URL aren't URLs"
            }

            self.privacyPolicyURL = privacyPolicyURL
            self.termsOfUseURL = termsOfUseURL
            self.version = version
        } catch {
            fatalError("ConfigManager init error: \(error)")
        }
    }
}
