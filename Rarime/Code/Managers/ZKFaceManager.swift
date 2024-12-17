import Foundation
import UIKit
import Vision

class ZKFaceManager {
    static let shared = ZKFaceManager()

    func extractFaceFromImage(_ image: UIImage) throws -> Data {
        let detectFaceRequest = VNDetectFaceCaptureQualityRequest()

        LoggerUtil.common.debug("image: \(image.pngData()!.base64EncodedString())")

        guard let cgImage = image.cgImage else {
            throw "Invalid image data"
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])

        try requestHandler.perform([detectFaceRequest])

        guard let results = detectFaceRequest.results else {
            throw "Failed to detect face"
        }

        if results.isEmpty {
            throw "No face detected"
        }

        LoggerUtil.common.debug("results len: \(results.count)")

        guard let faceImage = cgImage.cropImage(results[0]) else {
            throw "failed to crope face"
        }

        LoggerUtil.common.debug("results[0] x: \(results[0].boundingBox.width), y: \(results[0].boundingBox.height)")

        guard let faceData = UIImage(cgImage: faceImage).pngData() else {
            throw "Failed to convert face to data"
        }

        return faceData
    }
}

extension CGImage {
    func cropImage(_ face: VNFaceObservation) -> CGImage? {
        self.cropping(to: face.boundingBox)
    }
}
