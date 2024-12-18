import AVFoundation
import UIKit

public extension UIImage {
    func resize(_ width: Int, _ height: Int) throws -> UIImage {
        let dimantionSize = max(width, height)

        let maxSize = CGSize(width: dimantionSize, height: dimantionSize)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        guard let resizedCgImage = resized.cgImage else {
            throw "Invalid image data"
        }

        var x = 0
        var y = 0
        if width < height {
            var cropDifferential = Int(resized.size.width) - width
            if cropDifferential > 0 {
                x = cropDifferential / 2
            }
        } else {
            var cropDifferential = Int(resized.size.height) - height
            if cropDifferential > 0 {
                y = cropDifferential / 2
            }
        }

        guard let croppedCgImage = resizedCgImage.cropping(to: CGRect(x: x, y: y, width: width, height: height)) else {
            throw "Failed to crop image"
        }

        return UIImage(cgImage: croppedCgImage)
    }
}
