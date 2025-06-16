import SwiftUI

enum LikenessProcessingTask: Int, CaseIterable {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuits"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Creating rules"
        }
    }
    
    var progressTime: Int {
        switch self {
        case .downloadingCircuitData: return 7
        case .extractionImageFeatures: return 5
        case .runningZKMK: return 7
        }
    }
}

class LikenessFaceViewModel: ObservableObject {
    private var cameraManager = FaceCaptureSession(cameraPosition: .front)
    
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
