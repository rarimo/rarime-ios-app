import OSLog
import SwiftUI
import Identity

struct AppView: View {
    @EnvironmentObject private var circuitDataManager: CircuitDataManager
    @EnvironmentObject private var updateManager: UpdateManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var viewModel = ViewModel()
    
    @State private var isAlertPresented = false
    @State private var alert: Alert?

    var body: some View {
        ZStack {
            MainView()
        }
        .preferredColorScheme(settingsManager.colorScheme.rawScheme)
        .onReceive(AlertManager.shared.alertsSubject) { alert in
            self.isAlertPresented = true
            self.alert = alert
        }
        .alert(isPresented: $isAlertPresented) {
            self.alert ?? Alert(title: Text("Unknown"))
        }
        .environmentObject(viewModel)
        .onAppear {
            if userManager.user != nil { return }
            
            do {
                try userManager.createNewUser()
                
                try userManager.user?.save()
            } catch {
                LoggerUtil.common.error("crate user error: \(error)")
            }
        }
    }
}

#Preview {
    let userManager = UserManager()
    
    return AppView()
        .environmentObject(CircuitDataManager())
        .environmentObject(AlertManager())
        .environmentObject(SecurityManager())
        .environmentObject(SettingsManager())
        .environmentObject(UpdateManager())
        .environmentObject(PassportManager())
        .environmentObject(userManager)
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
