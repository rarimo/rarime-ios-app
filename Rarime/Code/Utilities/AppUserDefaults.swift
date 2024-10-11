import Foundation
import SwiftUI

public class AppUserDefaults: ObservableObject {
    public static let shared = AppUserDefaults()

    @AppStorage("is_intro_finished")
    public var isIntroFinished = false

    @AppStorage("passcode_state")
    public var passcodeState = SecurityItemState.unset.rawValue

    @AppStorage("face_id_state")
    public var faceIdState = SecurityItemState.unset.rawValue

    @AppStorage("passport_card_look")
    public var passportCardLook = PassportCardLook.black.rawValue

    @AppStorage("passport_identifiers")
    public var passportIdentifiers = try! JSONEncoder().encode([
        PassportIdentifier.nationality.rawValue,
        PassportIdentifier.documentId.rawValue,
    ])

    @AppStorage("is_passport_incognito_mode")
    public var isPassportIncognitoMode = false

    @AppStorage("color_scheme")
    public var colorScheme = AppColorScheme.system.rawValue

    @AppStorage("language")
    public var language = AppLanguage.english.rawValue

    @AppStorage("wallet_transactions")
    public var walletTransactions = Data()

    @AppStorage("is_airdrop_claimed")
    public var isAirdropClaimed = false

    @AppStorage("is_first_launch")
    public var isFirstLaunch = true

    @AppStorage("register_circuit_metadata")
    public var registerCircuitMetadata: Data = "{}".data(using: .utf8)!

    @AppStorage("is_circuit_data_downloaded")
    public var isCircuitDataDownloaded = false

    // Small hack to store Date in UserDefaults, because it's not supported by AppStorage
    public var banTimeEnd: Date? = UserDefaults.standard.object(forKey: "ban_time_end") as? Date {
        didSet {
            UserDefaults.standard.set(banTimeEnd, forKey: "ban_time_end")
        }
    }

    @AppStorage("is_user_revoked")
    public var isUserRevoked = false

    @AppStorage("userStatus")
    public var userStatus = User.Status.unscanned.rawValue

    @AppStorage("userRefarralCode")
    public var userReferralCode = ""

    @AppStorage("deferredReferralCode")
    public var deferredReferralCode = ""

    @AppStorage("is_circuits_storage_cleared")
    public var isCircuitsStorageCleared = false

    @AppStorage("isScanTutorialDisplayed")
    public var isScanTutorialDisplayed = false
}
