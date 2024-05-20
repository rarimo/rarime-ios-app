import Combine
import SwiftUI

class AlertManager: ObservableObject {
    static let shared = AlertManager()
    
    let alertsSubject = PassthroughSubject<Alert, Never>()
    
    func emitError(_ error: Errors) {
        alertsSubject.send(ErrorAlert(error))
    }
}
