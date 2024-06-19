import OSLog
import SwiftUI
import Identity

struct AppView: View {
    @EnvironmentObject private var circuitDataManager: CircuitDataManager
    @EnvironmentObject private var updateManager: UpdateManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @StateObject private var viewModel = ViewModel()
    
    @State private var isAlertPresented = false
    @State private var alert: Alert?

    var body: some View {
        ZStack {
            // TODO: It's look ugly
            if let isDeprecated = updateManager.isDeprecated {
                if isDeprecated {
                    VersionUpdateView()
                } else {
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
                        LockScreenView()
                    } else if securityManager.passcodeState != .unset {
                        EnableFaceIdView().transition(.backslide)
                    } else if viewModel.isIntroFinished {
                        EnablePasscodeView().transition(.backslide)
                    } else {
                        IntroView(onFinish: { viewModel.finishIntro() })
                            .transition(.backslide)
                    }
                }
            } else {
                ProgressView()
                    .controlSize(.large)
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
        .onAppear {
            Task { @MainActor in
                await updateManager.checkForUpdate()
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
        .environmentObject(CircuitDataManager())
        .environmentObject(AlertManager())
        .environmentObject(SecurityManager())
        .environmentObject(SettingsManager())
        .environmentObject(UpdateManager())
}
