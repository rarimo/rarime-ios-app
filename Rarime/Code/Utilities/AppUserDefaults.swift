import Foundation
import SwiftUI
import Web3

public class AppUserDefaults: ObservableObject {
    public static let shared = AppUserDefaults()

    @AppStorage("is_intro_finished")
    public var isIntroFinished = false

    @AppStorage("is_home_onboarding_completed")
    public var isHomeOnboardingCompleted = false

    @AppStorage("passcode_state")
    public var passcodeState = SecurityItemState.unset.rawValue

    @AppStorage("face_id_state")
    public var faceIdState = SecurityItemState.unset.rawValue

    @AppStorage("passport_card_look")
    public var passportCardLook = PassportCardLook.holographicViolet.rawValue

    @AppStorage("v2_passport_identifiers")
    public var passportIdentifiers = (try? JSONEncoder().encode([PassportIdentifier.documentId.rawValue])) ?? Data()

    @AppStorage("is_passport_incognito_mode")
    public var isPassportIncognitoMode = false

    @AppStorage("color_scheme")
    public var colorScheme = AppColorScheme.system.rawValue

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

    @AppStorage("is_registration_interrupted")
    public var isRegistrationInterrupted = false

    public var votedPollsIds: [Int] {
        get {
            return UserDefaults.standard.array(forKey: "voted_polls_ids") as? [Int] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "voted_polls_ids")
        }
    }

    @AppStorage("passport_processing_status")
    public var passportProcessingStatus: Int = PassportProcessingStatus.processing.rawValue

    @AppStorage("last_mrz_key")
    public var lastMRZKey: String = ""

    @AppStorage("likeness_rule")
    public var likenessRule: Int = LikenessRule.unset.rawValue

    @AppStorage("is_likeness_registered")
    public var isLikenessRegistered: Bool = false
    @AppStorage("is_passport_failed_by_impossible_revocation")
    public var isPassportFailedByImpossibleRevocation: Bool = false

    @AppStorage("home_widgets")
    public var homeWidgets: Data = (try? JSONEncoder().encode(DEFAULT_HOME_WIDGETS.map { $0.rawValue })) ?? Data()

    @AppStorage("has_points_balance")
    public var hasPointsBalance: Bool = false
}
