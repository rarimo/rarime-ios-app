import SwiftUI

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var passport: Passport? = nil
        @Published var passportCardLook: PassportCardLook = .black

        func setPassport(_ passport: Passport) {
            self.passport = passport
        }

        func removePassport() {
            passport = nil
            passportCardLook = .black
        }

        func setPassportCardLook(_ look: PassportCardLook) {
            passportCardLook = look
        }
    }
}
