import Foundation

enum ZkpVariants: Int, CaseIterable {
    case nullifier = 0
    case birthDate = 1
    case expirationDate = 2
    case name = 3
    case nationality = 4
    case citizenship = 5
    case sex = 6
    case documentNumber = 7
}

extension ZkpVariants {
    var title: String {
        switch self {
        case .nullifier:
            "Uniqueness"
        case .birthDate:
            "Birth date"
        case .expirationDate:
            "Expiration date"
        case .name:
            "Name"
        case .nationality:
            "Nationality"
        case .citizenship:
            "Citizenship"
        case .sex:
            "Sex"
        case .documentNumber:
            "Document number"
        }
    }
}
