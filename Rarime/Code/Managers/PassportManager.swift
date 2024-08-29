import SwiftUI

class PassportManager: ObservableObject {
    static let shared = PassportManager()

    @Published private(set) var passport: Passport?
    @Published private(set) var passportCardLook: PassportCardLook
    @Published private(set) var passportIdentifiers: [PassportIdentifier]
    @Published private(set) var isIncognitoMode: Bool

    init() {
        if let passport = try? AppKeychain.getValue(.passport) {
            self.passport = try? JSONDecoder().decode(Passport.self, from: passport)
        }
        passportCardLook = PassportCardLook(rawValue: AppUserDefaults.shared.passportCardLook)!
        isIncognitoMode = AppUserDefaults.shared.isPassportIncognitoMode

        let rawIdentifiers = try! JSONDecoder().decode([String].self, from: AppUserDefaults.shared.passportIdentifiers)
        passportIdentifiers = rawIdentifiers.map { PassportIdentifier(rawValue: $0)! }
    }

    var isEligibleForAirdrop: Bool {
        passport?.nationality == "UKR"
    }

    var passportCountry: Country {
        .fromISOCode(passport?.nationality ?? "")
    }

    var isUnsupportedForRewards: Bool {
        UNSUPPORTED_REWARD_COUNTRIES.contains(passportCountry) || passport?.isExpired ?? true
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
        setPassportCardLook(.white)
        setIncognitoMode(true)
        try? AppKeychain.setValue(.passport, JSONEncoder().encode(passport))
    }

    func setPassportCardLook(_ look: PassportCardLook) {
        passportCardLook = look
        AppUserDefaults.shared.passportCardLook = look.rawValue
    }

    func setIncognitoMode(_ isIncognito: Bool) {
        isIncognitoMode = isIncognito
        AppUserDefaults.shared.isPassportIncognitoMode = isIncognito
    }

    func setPassportIdentifiers(_ identifiers: [PassportIdentifier]) {
        passportIdentifiers = identifiers
        AppUserDefaults.shared.passportIdentifiers = try! JSONEncoder().encode(identifiers.map { $0.rawValue })
    }

    func reset() {
        passport = nil
        try? AppKeychain.removeValue(.passport)
        setPassportCardLook(.white)
        setPassportIdentifiers([.nationality, .documentId])
        setIncognitoMode(true)
    }
}
