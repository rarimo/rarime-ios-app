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

    @AppStorage("color_scheme")
    public var colorScheme = AppColorScheme.system.rawValue

    @AppStorage("language")
    public var language = AppLanguage.engish.rawValue

    @AppStorage("wallet_balance")
    public var walletBalance = 0.0

    @AppStorage("wallet_transactions")
    public var walletTransactions = Data()

    @AppStorage("is_airdrop_claimed")
    public var isAirdropClaimed = false
}
