import SwiftUI

class ContractABI {
    static let registrationAbiJSON = NSDataAsset(name: "RegistrationAbi.json")?.data ?? Data()
    
    static let poseidonSMTAbiJSON = NSDataAsset(name: "PoseidonSMTAbi.json")?.data ?? Data()
}
