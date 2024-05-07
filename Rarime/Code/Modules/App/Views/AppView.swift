import SwiftUI

struct AppView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @StateObject private var viewModel = ViewModel()

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
    }
}

#Preview {
    AppView()
        .environmentObject(SecurityManager())
        .environmentObject(SettingsManager())
}
