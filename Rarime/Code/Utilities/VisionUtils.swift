import CoreImage.CIFilterBuiltins
import SwiftUI
import Vision

class VisionUtils {
    static func removeBackground(_ image: UIImage) -> UIImage {
        guard #available(iOS 17, *), let inputImage = CIImage(image: image) else {
            LoggerUtil.common.info("VisionUtils: Remove background failed: iOS 17+ required or invalid image")
            return image
        }

        guard let maskImage = generateMask(from: inputImage) else {
            LoggerUtil.common.error("VisionUtils: Failed to create mask image")
            return image
        }

        let filter = CIFilter.blendWithMask()
        filter.inputImage = inputImage
        filter.maskImage = maskImage
        filter.backgroundImage = CIImage.empty()

        guard let filteredImage = filter.outputImage else {
            LoggerUtil.common.error("VisionUtils: Failed to apply mask")
            return image
        }

        guard let cgImage = CIContext().createCGImage(filteredImage, from: filteredImage.extent) else {
            LoggerUtil.common.error("VisionUtils: Failed to render image")
            return image
        }

        return UIImage(cgImage: cgImage)
    }

    private static func generateMask(from inputImage: CIImage) -> CIImage? {
        guard #available(iOS 17, *) else {
            return nil
        }

        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()

        do {
            try handler.perform([request])
        } catch {
            LoggerUtil.common.error("VisionUtils: Error performing mask request: \(error)")
            return nil
        }

        guard let result = request.results?.first else {
            LoggerUtil.common.error("VisionUtils: No observations found")
            return nil
        }

        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            LoggerUtil.common.error("VisionUtils: Error generating mask: \(error)")
            return nil
        }
    }
}
