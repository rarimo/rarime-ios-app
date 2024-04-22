import Foundation

enum SecurityItemState: Int {
    case unset, enabled, disabled
}

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()

    @Published private(set) var passcodeState: SecurityItemState {
        didSet {
            AppUserDefaults.shared.passcodeState = passcodeState.rawValue
        }
    }

    @Published private(set) var faceIdState: SecurityItemState {
        didSet {
            AppUserDefaults.shared.faceIdState = faceIdState.rawValue
        }
    }

    @Published private(set) var passcode: String

    init() {
        passcodeState = SecurityItemState(rawValue: AppUserDefaults.shared.passcodeState)!
        faceIdState = SecurityItemState(rawValue: AppUserDefaults.shared.faceIdState)!
        passcode = try! AppKeychain.getValue(.passcode) ?? ""
    }

    func enablePasscode(_ newPasscode: String) {
        passcodeState = .enabled
        passcode = newPasscode
        try? AppKeychain.setValue(.passcode, newPasscode)
    }

    func disablePasscode() {
        passcodeState = .disabled
        passcode = ""
        try? AppKeychain.removeValue(.passcode)
    }

    func enableFaceId() {
        faceIdState = .enabled
    }

    func disableFaceId() {
        faceIdState = .disabled
    }
}
