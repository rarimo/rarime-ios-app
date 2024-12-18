import Foundation
import SwiftUI

class ZKFaceModel {
    static let matrix = try! JSONDecoder().decode([[Double]].self, from: NSDataAsset(name: "matrix")!.data)

    static let mean = try! JSONDecoder().decode([Double].self, from: NSDataAsset(name: "mean")!.data)
}
