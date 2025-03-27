import SwiftUI

class Circuits {
    static let queryIdentityDat = NSDataAsset(name: "queryIdentityDat")?.data ?? Data()
    static let queryIdentityZkey = NSDataAsset(name: "queryIdentityZkey")?.data ?? Data()

    static let authDat = NSDataAsset(name: "authDat")?.data ?? Data()
    static let authZkey = NSDataAsset(name: "authZkey")?.data ?? Data()

    static let noirRegisterCircuit = Data()
    static let registerIdentity_25_384_1_3_256_336_NA = Data()
    static let registerIdentity_21_256_3_3_224_336_NA = NSDataAsset(name: "registerIdentity_21_256_3_3_224_336_NA")!.data
}
