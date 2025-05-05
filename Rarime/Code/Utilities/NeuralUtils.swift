import Foundation

import UIKit
import Vision

class NeuralUtils {
    func extractFaceFromImage(_ image: UIImage) throws -> UIImage? {
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
            return nil
        }

        return try extractFaceFromImageObservation(results[0], cgImage)
    }
}

private func extractFaceFromImageObservation(
    _ faceObservation: VNFaceObservation,
    _ image: CGImage
) throws -> UIImage {
    let boundingBox = faceObservation.boundingBox
    let size = CGSize(width: boundingBox.width * CGFloat(image.width), height: boundingBox.height * CGFloat(image.height))
    let origin = CGPoint(x: boundingBox.minX * CGFloat(image.width), y: (1 - boundingBox.maxY) * CGFloat(image.height))
    let rect = CGRect(origin: origin, size: size)

    guard let faceCgImage = image.cropping(to: rect) else {
        throw "Failed to crop face"
    }

    return UIImage(cgImage: faceCgImage)
}
