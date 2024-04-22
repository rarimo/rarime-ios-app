import SwiftUI

class PassportManager: ObservableObject {
    static let shared = PassportManager()

    @Published private(set) var passport: Passport?
    @Published private(set) var passportCardLook: PassportCardLook

    init() {
        if let passport = try? AppKeychain.getValue(.passport) {
            self.passport = try? JSONDecoder().decode(Passport.self, from: passport.data(using: .utf8)!)
        }
        passportCardLook = PassportCardLook(rawValue: AppUserDefaults.shared.passportCardLook)!
    }

    var isEligibleForReward: Bool {
        passport?.nationality == "UKR"
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
        try? AppKeychain.setValue(.passport, try String(data: JSONEncoder().encode(passport), encoding: .utf8)!)
    }

    func removePassport() {
        passport = nil
        passportCardLook = .black

        try? AppKeychain.removeValue(.passport)
        AppUserDefaults.shared.passportCardLook = passportCardLook.rawValue
    }

    func setPassportCardLook(_ look: PassportCardLook) {
        passportCardLook = look
        AppUserDefaults.shared.passportCardLook = look.rawValue
    }
}
