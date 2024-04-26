import SwiftUI

class PassportManager: ObservableObject {
    static let shared = PassportManager()

    @Published private(set) var passport: Passport?
    @Published private(set) var passportCardLook: PassportCardLook
    @Published private(set) var isIncognitoMode: Bool

    init() {
        if let passport = try? AppKeychain.getValue(.passport) {
            self.passport = try? JSONDecoder().decode(Passport.self, from: passport.data(using: .utf8)!)
        }
        passportCardLook = PassportCardLook(rawValue: AppUserDefaults.shared.passportCardLook)!
        isIncognitoMode = AppUserDefaults.shared.isPassportIncognitoMode
    }

    var isEligibleForReward: Bool {
        passport?.nationality == "UKR"
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
        setPassportCardLook(.white)
        setIncognitoMode(true)
        try? AppKeychain.setValue(.passport, try String(data: JSONEncoder().encode(passport), encoding: .utf8)!)
    }

    func removePassport() {
        passport = nil
        try? AppKeychain.removeValue(.passport)
    }

    func setPassportCardLook(_ look: PassportCardLook) {
        passportCardLook = look
        AppUserDefaults.shared.passportCardLook = look.rawValue
    }

    func setIncognitoMode(_ isIncognito: Bool) {
        isIncognitoMode = isIncognito
        AppUserDefaults.shared.isPassportIncognitoMode = isIncognito
    }
}
