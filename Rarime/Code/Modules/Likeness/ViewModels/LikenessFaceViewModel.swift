import Web3

import SwiftUI

protocol LikenessProcessingTask: CaseIterable {
    var rawValue: Int { get }
    var description: String { get }
    var progressTime: Int { get }
}

enum LikenessProcessingRegisterTask: Int, CaseIterable, LikenessProcessingTask {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKML"
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
    @Published var maskFrame: UIImage?
    @Published var currentFrame: CGImage?
        
    private var cameraManager = FaceCaptureSession()
        
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
                maskFrame = try ImageMasks.processFace(image)
                
                currentFrame = image
            }
        }
    }
    
    func clearImages() {
        currentFrame = nil
    }
}
