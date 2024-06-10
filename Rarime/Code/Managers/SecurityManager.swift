import Foundation

enum SecurityItemState: Int {
    case unset, enabled, disabled
}

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()

    @Published var passcodeState: SecurityItemState {
        didSet {
            AppUserDefaults.shared.passcodeState = passcodeState.rawValue
        }
    }

    @Published var faceIdState: SecurityItemState {
        didSet {
            AppUserDefaults.shared.faceIdState = faceIdState.rawValue
        }
    }

    @Published private(set) var passcode: String

    @Published var isPasscodeCorrect: Bool

    init() {
        let passcodeState = SecurityItemState(rawValue: AppUserDefaults.shared.passcodeState)!
        let faceIdState = SecurityItemState(rawValue: AppUserDefaults.shared.faceIdState)!

        let passcodeBytes = (try? AppKeychain.getValue(.passcode) ?? Data()) ?? Data()

        self.passcode = passcodeBytes.utf8
        self.isPasscodeCorrect = passcodeState != .enabled
        self.passcodeState = passcodeState
        self.faceIdState = faceIdState
    }

    func enablePasscode() {
        passcodeState = .unset
    }

    func setPasscode(_ newPasscode: String) {
        passcodeState = .enabled

        passcode = newPasscode
        try? AppKeychain.setValue(.passcode, newPasscode.data(using: .utf8) ?? Data())
    }

    func disablePasscode() {
        passcodeState = .disabled
        disableFaceId()
        try? AppKeychain.removeValue(.passcode)
    }

    func enableFaceId() {
        faceIdState = .enabled
    }

    func disableFaceId() {
        faceIdState = .disabled
    }

    func reset() {
        passcodeState = .unset
        faceIdState = .unset
        passcode = ""
        isPasscodeCorrect = true
        try? AppKeychain.removeValue(.passcode)
    }
}
