import SwiftUI

extension BiometryRecoveryView {
    class ViewModel: ObservableObject {
        @Published var currentFrame: CGImage?
        
        private let cameraManager = BiomatryCaptureSession()
        
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
        
        func handleCameraPreviews() async {
            for await image in cameraManager.previewStream {
                Task { @MainActor in
                    currentFrame = image
                }
            }
        }
    }
}
