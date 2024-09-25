import CoreImage

extension CIImage {
    var cgImage: CGImage? {
        return CIContext().createCGImage(self, from: self.extent)
    }
}
