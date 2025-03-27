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
        VStack {}
            .onAppear {
                do {
                    let inputsData = NSDataAsset(name: "inputs")!.data

                    let inputs = try JSONDecoder().decode(NoirRegisterIdentityInputs.self, from: inputsData)

                    _ = try ZKUtils.generateCustomNoirProof(inputs, Circuits.registerIdentity_21_256_3_3_224_336_NA)
                } catch {
                    LoggerUtil.common.error("error: \(error)")
                }
            }
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
