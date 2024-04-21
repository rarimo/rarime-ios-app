import Foundation

extension AppView {
    class ViewModel: ObservableObject {
        @Published var isIntroFinished = AppUserDefaults.shared.isIntroFinished

        func finishIntro() {
            isIntroFinished = true
            AppUserDefaults.shared.isIntroFinished = true
        }
    }
}
