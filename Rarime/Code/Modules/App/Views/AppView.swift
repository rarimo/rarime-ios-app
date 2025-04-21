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

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) var scenePhase

    @State var blurRadius: CGFloat = 0
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
            } else {
                VStack {
                    Spacer()
                    Image(Icons.rarime)
                        .square(96)
                        .foregroundStyle(Gradients.gradientFirst)
                        .padding(.all, 44)
                        .background(.baseBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 48))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.bgPrimary)
            }
            AlertManagerView()
        }
        .colorScheme(settingsManager.colorScheme.rawScheme ?? colorScheme)
        .blur(radius: blurRadius)
        .animation(.easeOut(duration: 0.1), value: blurRadius)
        .onChange(of: scenePhase, perform: { value in
            switch value {
            case .active: withAnimation { blurRadius = 0 }
            case .inactive: withAnimation { blurRadius = 15 }
            case .background: blurRadius = 20
            @unknown default: LoggerUtil.common.error("Unknown scene phase")
            }
        })
        .onAppear {
            LoggerUtil.common.info("Application started")

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
