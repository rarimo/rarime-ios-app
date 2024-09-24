import AVFoundation
import CoreImage

extension CMSampleBuffer {
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        
        guard let imagePixelBuffer = pixelBuffer else { return nil }
        
        guard let cgimage = CIImage(cvPixelBuffer: imagePixelBuffer).cgImage else { return nil }
        
        return cgimage
    }
}
