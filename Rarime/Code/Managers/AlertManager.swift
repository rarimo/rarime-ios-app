import Combine
import SwiftUI
import UIKit

struct AppAlertSubject: Equatable {
    let type: AppAlertType
    let message: String?
}

class AlertManager: ObservableObject {
    static let shared = AlertManager()

    func emitError(_ error: Errors) {
        AlertPresenter().show(AppAlertSubject(type: .error, message: error.localizedDescription))
    }

    func emitError(_ message: String) {
        AlertPresenter().show(AppAlertSubject(type: .error, message: message))
    }

    func emitSuccess(_ message: String) {
        AlertPresenter().show(AppAlertSubject(type: .success, message: message))
    }

    func emitProcessing(_ message: String) {
        AlertPresenter().show(AppAlertSubject(type: .processing, message: message))
    }
}

private let ALERT_WINDOW_HEIGHT: CGFloat = 100
private let ALERT_DURATION: TimeInterval = 5 // seconds

// Reference: https://gist.github.com/tciuro/059cb9a82b9dcdebbb87644db6fe90bd
class AlertPresenter {
    private var alertWindow: UIWindow?

    func show(_ alert: AppAlertSubject) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        alertWindow = UIWindow(windowScene: scene)
        alertWindow?.backgroundColor = .clear
        alertWindow?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: ALERT_WINDOW_HEIGHT)

        if alert.type == .success {
            FeedbackGenerator.shared.notify(.success)
        } else if alert.type == .error {
            FeedbackGenerator.shared.notify(.error)
        }

        func hide() {
            UIView.animate(withDuration: 0.25, animations: {
                self.alertWindow?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: ALERT_WINDOW_HEIGHT)
            }) { _ in
                self.alertWindow?.isHidden = true
                self.alertWindow = nil
            }
        }

        alertWindow?.rootViewController = UIHostingController(
            rootView: AppAlert(type: alert.type, message: alert.message)
                .onTapGesture(perform: hide)
        )
        alertWindow?.rootViewController?.view.backgroundColor = .clear
        alertWindow?.makeKeyAndVisible()

        UIView.animate(withDuration: 0.25, animations: {
            self.alertWindow?.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: ALERT_WINDOW_HEIGHT)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + ALERT_DURATION) {
            hide()
        }
    }
}
