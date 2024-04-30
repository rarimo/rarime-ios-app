import SwiftUI

struct AppView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            // With the new circuit version, we are going to get rid of this
            // in favor of the embedded circuit data
            if !viewModel.isCircuitDataDownloaded {
                PreDownloadView(onFinish: viewModel.finishCircuitDataDownloading).transition(.backslide)
            } else if securityManager.faceIdState != .unset {
                MainView().transition(.backslide)
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
