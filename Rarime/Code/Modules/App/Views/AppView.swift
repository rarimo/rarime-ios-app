import OSLog
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @StateObject private var viewModel = ViewModel()
    
    @State private var isAlertPresented = false
    @State private var alert: Alert?

    var body: some View {
        ZStack {
            if
                securityManager.passcodeState != .unset,
                securityManager.faceIdState != .unset,
                securityManager.isPasscodeCorrect
            {
                MainView().transition(.backslide)
            } else if
                securityManager.passcodeState != .unset,
                securityManager.faceIdState != .unset
            {
                CheckPassportView()
            } else if securityManager.passcodeState != .unset {
                EnableFaceIdView().transition(.backslide)
            } else if viewModel.isIntroFinished {
                EnablePasscodeView().transition(.backslide)
            } else {
                IntroView(onFinish: { viewModel.finishIntro() })
                    .transition(.backslide)
            }
        }
        .preferredColorScheme(settingsManager.colorScheme.rawScheme)
        .onReceive(AlertManager.shared.alertsSubject) { alert in
            self.isAlertPresented = true
            self.alert = alert
        }
        .alert(isPresented: $isAlertPresented) {
            self.alert ?? Alert(title: Text("Unknown"))
        }
    }
}

#Preview {
    AppView()
        .environmentObject(AlertManager())
        .environmentObject(SecurityManager())
        .environmentObject(SettingsManager())
}
