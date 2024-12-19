import SwiftUI

extension BiometryRecoveryView {
    class ViewModel: ObservableObject {
        @Published var currentFrame: CGImage?
        @Published var faceImage: UIImage?
        
        private let cameraManager = BiomatryCaptureSession()
        
        @Published var cameraTask: Task<Void, Never>? = nil
        
        @Published var loadingProgress = 0.0
        
        func startScanning() {
            cameraTask = Task {
                await cameraManager.startSession()
                
                await handleCameraPreviews()
            }
        }
        
        func stopScanning() {
            cameraManager.stopSession()
            
            cameraTask?.cancel()
        }
        
        func handleCameraPreviews() async {
            for await image in cameraManager.previewStream {
                Task { @MainActor in
                    currentFrame = image
                    
                    handleFaceImage(image)
                }
            }
        }
        
        func handleFaceImage(_ image: CGImage) {
            Task { @MainActor in
                do {
                    let faceImage = try ZKFaceManager.shared.extractFaceFromImage(UIImage(cgImage: image))
                    guard let faceImage = faceImage else {
                        if loadingProgress > 0 {
                            loadingProgress -= 0.01
                        }
                        
                        return
                    }
                    
                    if loadingProgress == 1 {
                        self.faceImage = faceImage
                    }
                    
                    loadingProgress += 0.01
                } catch {
                    LoggerUtil.common.info("Error extracting face: \(error)")
                }
            }
        }
    }
}
