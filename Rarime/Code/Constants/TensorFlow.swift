import SwiftUI

class TensorFlow {
    static var bioNetV3: Data { NSDataAsset(name: "BioNetV3")!.data }

    static var bionetImageBoundary: Int = 40

    static var faceRecognitionImageBoundary: Int = 112
}
