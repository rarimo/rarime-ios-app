import SwiftUI

class Circuits {
    static let queryIdentityDat = NSDataAsset(name: "queryIdentityDat")?.data ?? Data()
    static let queryIdentityZkey = NSDataAsset(name: "queryIdentityZkey")?.data ?? Data()

    static let authDat = NSDataAsset(name: "authDat")?.data ?? Data()
    static let authZkey = NSDataAsset(name: "authZkey")?.data ?? Data()

    static let faceRegistryNoInclusionDat = NSDataAsset(name: "faceRegistryNoInclusion.dat")?.data ?? Data()
    static let faceRegistryNoInclusionZkey = NSDataAsset(name: "faceRegistryNoInclusion.zkey")?.data ?? Data()
}
