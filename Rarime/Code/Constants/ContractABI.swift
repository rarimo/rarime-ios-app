import SwiftUI

class ContractABI {
    static let registrationAbiJSON = NSDataAsset(name: "RegistrationAbi.json")?.data ?? Data()
    
    static let poseidonSMTAbiJSON = NSDataAsset(name: "PoseidonSMTAbi.json")?.data ?? Data()
    
    static let stateKeeperAbiJSON = NSDataAsset(name: "StateKeeperAbi.json")?.data ?? Data()
    
    static let proposalsStateAbiJSON = NSDataAsset(name: "ProposalsStateAbi.json")?.data ?? Data()
    
    static let multicall3AbiJSON = NSDataAsset(name: "Multicall3Abi.json")?.data ?? Data()
    
    static let faceRegistryAbi = NSDataAsset(name: "FaceRegistryAbi.json")?.data ?? Data()
}
