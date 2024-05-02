import Foundation

extension AppView {
    class ViewModel: ObservableObject {
        @Published var isIntroFinished = AppUserDefaults.shared.isIntroFinished
        @Published var isCircuitDataDownloaded = AppUserDefaults.shared.isCircuitDataDownloaded

        func finishIntro() {
            DispatchQueue.main.async {
                self.isIntroFinished = true
                AppUserDefaults.shared.isIntroFinished = true
            }
        }
        
        func finishCircuitDataDownloading() {
            DispatchQueue.main.async {
                self.isCircuitDataDownloaded = true
                AppUserDefaults.shared.isCircuitDataDownloaded = true
            }
        }
    }
}
