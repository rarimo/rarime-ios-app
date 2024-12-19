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
                ProgressView()
                    .controlSize(.large)
            }
            AlertManagerView()
        }
        .preferredColorScheme(settingsManager.colorScheme.rawScheme)
        .onAppear {
            Task { @MainActor in
                await updateManager.checkForUpdate()
            }

            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onAppear {
            Task {
                do {
                    let testImage = UIImage(named: "TestImage")!

                    let extractedImage = try ZKFaceManager.shared.extractFaceFromImage(testImage)

                    let (_, grayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(extractedImage)

                    let computableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(grayscalePixelsData)

                    let features = ZKFaceManager.shared.extractFeaturesFromComputableModel(computableModel)

                    LoggerUtil.common.debug("Image processing finished: \(features.json.utf8)")

                    let inputs = CircuitBuilderManager.shared.fisherFaceCircuit.buildInputs(computableModel, features)

                    // coput inputs to clipbord
                    UIPasteboard.general.string = inputs.json.utf8

                    let thread = Thread {
                        do {
                            let wtns = try ZKUtils.calcWtnsFisherface(inputs.json)

                            let (proofJson, pubSignalsJson) = try ZKUtils.groth16Fisherface(wtns)

                            let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
                            let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)

                            let zkProof = ZkProof(proof: proof, pubSignals: pubSignals)

                            LoggerUtil.common.debug("zkProof: \(zkProof.json.utf8)")
                        } catch {
                            LoggerUtil.common.debug("error: \(error)")
                        }
                    }

                    thread.stackSize = 100 * 1024 * 1024

                    thread.start()

                } catch {
                    LoggerUtil.common.debug("error: \(error)")
                }
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
        .environmentObject(InternetConnectionManager())
}
