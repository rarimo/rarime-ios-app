import Identity
import OSLog
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var internetConnectionManager: InternetConnectionManager
    @EnvironmentObject private var circuitDataManager: CircuitDataManager
    @EnvironmentObject private var updateManager: UpdateManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            // TODO: It's look ugly
            if let isDeprecated = updateManager.isDeprecated {
                if isDeprecated {
                    VersionUpdateView()
                } else if !internetConnectionManager.isInternetPresent {
                    InternetConnectionRequiredView()
                } else if updateManager.isMaintenance {
                    MaintenanceView()
                } else if
                    securityManager.passcodeState != .unset,
                    securityManager.faceIdState != .unset,
                    securityManager.isPasscodeCorrect
                {
                    V2MainView().transition(.backslide)
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
            } else {
                Spacer()
                Image(.rarime)
                    .square(96)
                    .foregroundStyle(Gradients.gradientFirst)
                    .padding(.all, 44)
                    .background(.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 48))
                Spacer()
            }
            AlertManagerView()
        }
        .preferredColorScheme(settingsManager.colorScheme.rawScheme)
        .onAppear {
            Task { @MainActor in
                await updateManager.checkMaintenanceMode()
                await updateManager.checkForUpdate()
            }

            UIApplication.shared.isIdleTimerDisabled = true
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
        .environmentObject(InternetConnectionManager())
}
