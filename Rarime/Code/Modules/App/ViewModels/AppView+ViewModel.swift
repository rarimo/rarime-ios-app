import Foundation

extension AppView {
    class ViewModel: ObservableObject {
        @Published var isIntroFinished = AppUserDefaults.shared.isIntroFinished {
            didSet {
                AppUserDefaults.shared.isIntroFinished = isIntroFinished
            }
        }

        @Published var isCircuitDataDownloaded = AppUserDefaults.shared.isCircuitDataDownloaded {
            didSet {
                AppUserDefaults.shared.isCircuitDataDownloaded = isCircuitDataDownloaded
            }
        }

        func finishIntro() {
            DispatchQueue.main.async {
                self.isIntroFinished = true
            }
        }

        func finishCircuitDataDownloading() {
            DispatchQueue.main.async {
                self.isCircuitDataDownloaded = true
            }
        }
    }
}
