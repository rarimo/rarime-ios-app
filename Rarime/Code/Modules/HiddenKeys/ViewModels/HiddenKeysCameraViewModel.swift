import SwiftUI

class HiddenKeysCameraViewModel: ObservableObject {
    private var cameraManager = FaceCaptureSession(cameraPosition: .back)
    
    @Published var currentFrame: CGImage?
    @Published var maskFrame: UIImage?
    @Published var cameraTask: Task<Void, Never>? = nil
        
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
    
    func pauseScanning() {
        cameraManager.stopSession()
    }
        
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
                maskFrame = try ImageMasks.processFace(image)
            }
        }
    }
        
    func clearImages() {
        currentFrame = nil
        maskFrame = nil
    }
}
