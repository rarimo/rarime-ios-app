import Foundation
import UIKit
import Vision

class ZKFaceManager {
    static let shared = ZKFaceManager()

    func extractFaceFromImage(_ image: UIImage) throws -> Data {
        let detectFaceRequest = VNDetectFaceCaptureQualityRequest()

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

        let faceObservation = results[0]
        let boundingBox = faceObservation.boundingBox
        let size = CGSize(width: boundingBox.width * CGFloat(cgImage.width), height: boundingBox.height * CGFloat(cgImage.height))
        let origin = CGPoint(x: boundingBox.minX * CGFloat(cgImage.width), y: (1 - boundingBox.maxY) * CGFloat(cgImage.height))
        let rect = CGRect(origin: origin, size: size)

        guard let faceCgImage = cgImage.cropping(to: rect) else {
            throw "Failed to crop face"
        }

        guard let faceData = UIImage(cgImage: faceCgImage).pngData() else {
            throw "Failed to convert face to data"
        }

        return faceData
    }
}
