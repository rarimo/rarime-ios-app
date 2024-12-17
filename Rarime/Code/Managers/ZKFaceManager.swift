import Foundation
import UIKit
import Vision

class ZKFaceManager {
    static let shared = ZKFaceManager()

    static let grayscaleWidthInPixels: Int = 92
    static let grayscaleHeightInPixels: Int = 112

    func extractFaceFromImage(_ image: UIImage) throws -> UIImage {
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

        return UIImage(cgImage: faceCgImage)
    }

    func convertFaceToGrayscale(_ image: UIImage) throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw "Invalid image data"
        }

        let width = cgImage.width
        let height = cgImage.height

        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let grayscaleCgImage = context?.makeImage() else {
            throw "Failed to convert image to grayscale"
        }

        return UIImage(cgImage: grayscaleCgImage)
    }
}
