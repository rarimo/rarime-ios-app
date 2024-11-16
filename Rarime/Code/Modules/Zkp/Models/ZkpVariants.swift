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

    var template: String {
        switch self {
        case .nullifier:
            "701fd6f18a46f7c72397c91b9cb1a6353744b9cca3aa329af5e5e1124b6b8c5a"
        case .birthDate:
            "39382f30362f3132"
        case .expirationDate:
            "32362f31302f3130"
        case .name:
            "4f6c6578616e646572"
        case .nationality:
            "554b52"
        case .citizenship
             "554b52"
             case .sex:
            "4d"
        case .documentNumber:
            "444e343332343235"
        }
    }
}
