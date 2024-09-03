import Combine
import SwiftUI

struct AppAlertSubject: Equatable {
    let type: AppAlertType
    let message: String?
}

class AlertManager: ObservableObject {
    static let shared = AlertManager()

    let alertsSubject = PassthroughSubject<Alert, Never>()
    let subject = PassthroughSubject<AppAlertSubject, Never>()

    func emitError(_ error: Errors) {
        subject.send(AppAlertSubject(type: .error, message: error.localizedDescription))
    }

    func emitSuccess(_ message: String) {
        subject.send(AppAlertSubject(type: .success, message: message))
    }

    func emitProcessing(_ message: String) {
        subject.send(AppAlertSubject(type: .processing, message: message))
    }
}
