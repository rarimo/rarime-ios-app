import Web3

import SwiftUI

protocol LikenessProcessingTask: CaseIterable {
    var rawValue: Int { get }
    var description: String { get }
    var progressTime: Int { get }
}

enum LikenessProcessingRecoveryTask: Int, LikenessProcessingTask {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case overridingAccess = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKML"
        case .overridingAccess: return "Overriding access"
        }
    }
    
    var progressTime: Int {
        switch self {
        case .downloadingCircuitData: return 15
        case .extractionImageFeatures: return 5
        case .runningZKMK: return 10
        case .overridingAccess: return 7
        }
    }
}

enum LikenessProcessingRegisterTask: Int, CaseIterable, LikenessProcessingTask {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case creatingAccount = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKML"
        case .creatingAccount: return "Registering recovery method"
        }
    }
    
    var progressTime: Int {
        switch self {
        case .downloadingCircuitData: return 7
        case .extractionImageFeatures: return 3
        case .runningZKMK: return 5
        case .creatingAccount: return 4
        }
    }
}

class LikenessFaceViewModel: ObservableObject {
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
                currentFrame = image
                handleFaceImage(image)
            }
        }
    }
        
    func handleFaceImage(_ image: CGImage) {}
    
    func clearImages() {
        currentFrame = nil
    }
}
