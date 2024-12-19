import Foundation
import UIKit
import Vision

class ZKFaceManager {
    static let shared = ZKFaceManager()

    static let grayscaleWidthInPixels: Int = 92
    static let grayscaleHeightInPixels: Int = 112

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

    func convertFaceToGrayscale(_ image: UIImage) throws -> (UIImage, Data) {
        let preProcessedImage = try image.resize(ZKFaceManager.grayscaleWidthInPixels, ZKFaceManager.grayscaleHeightInPixels)

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

    func convertGrayscaleDataToComputableModel(_ grayscaleData: Data) -> [Double] {
        return grayscaleData.map { Double($0) / 255.0 }
    }

    func extractFeaturesFromComputableModel(_ model: [Double]) -> [Double] {
        var subImage = [Double](repeating: 0, count: model.count)
        for pixelIndex in 0 ..< subImage.count {
            subImage[pixelIndex] = model[pixelIndex] - ZKFaceModel.mean[pixelIndex]
        }

        var features = [Double](repeating: 0, count: ZKFaceModel.matrix.count)
        for featureIndex in 0 ..< features.count {
            for weightIndex in 0 ..< ZKFaceModel.matrix[featureIndex].count {
                features[featureIndex] += ZKFaceModel.matrix[featureIndex][weightIndex] * subImage[weightIndex]
            }
        }

        return features
    }
}
