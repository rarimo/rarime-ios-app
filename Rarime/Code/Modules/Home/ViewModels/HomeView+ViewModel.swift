import SwiftUI

let passport = Passport(
    firstName: "Joshua",
    lastName: "Smith",
    gender: "M",
    passportImage: nil,
    documentType: "P",
    issuingAuthority: "USA",
    documentNumber: "00AA00000",
    documentExpiryDate: "900314",
    dateOfBirth: "970314",
    nationality: "USA"
)

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
