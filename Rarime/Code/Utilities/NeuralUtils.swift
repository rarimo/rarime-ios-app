import Foundation

import UIKit
import Vision

class NeuralUtils {
    static func extractFaceFromImage(_ image: UIImage) throws -> UIImage? {
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

    static func convertFaceToGrayscaleData(_ image: UIImage, _ boundary: Int) throws -> (UIImage, Data) {
        let preProcessedImage = try image.resize(boundary, boundary)

        guard let cgImage = preProcessedImage.cgImage else {
            throw "Invalid image data"
        }

        let width = cgImage.width
        let height = cgImage.height

        let dataSize = width * height
        var pixelsData = [UInt8](repeating: 0, count: Int(dataSize))
        let context = CGContext(
            data: &pixelsData,
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

        return (UIImage(cgImage: grayscaleCgImage), Data(pixelsData))
    }

    static func normalizeModel(_ model: Data) -> [Float] {
        return model.map { Float($0) / 255.0 }
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
