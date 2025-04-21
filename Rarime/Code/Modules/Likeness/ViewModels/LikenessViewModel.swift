import Web3

import SwiftUI

protocol SetupActionTask: CaseIterable {
    var rawValue: Int { get }
    var description: String { get }
    var progressTime: Int { get }
}

enum SetupRecoveryTask: Int, SetupActionTask {
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

enum SetupRegisterTask: Int, CaseIterable, SetupActionTask {
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
        case .downloadingCircuitData: return 15
        case .extractionImageFeatures: return 5
        case .runningZKMK: return 10
        case .creatingAccount: return 7
        }
    }
}

class LikenessViewModel: ObservableObject {
    @Published var currentFrame: CGImage?
    @Published var faceImage: UIImage?

    var faceImages: [UIImage] = []
        
    private let cameraManager = FaceCaptureSession()
        
    @Published var cameraTask: Task<Void, Never>? = nil
        
    @Published var loadingProgress = 0.0
        
    @Published var recoveryProgress: SetupRecoveryTask? = nil
    @Published var registerProgress: SetupRegisterTask? = nil
        
    @Published var processingTask: Task<Void, Never>? = nil
        
    private var recentZKProofResult: Result<ZkProof, Error>?
        
    @MainActor
    func markRecoveryProgress(_ progress: SetupRecoveryTask) {
        recoveryProgress = progress
    }
    
    @MainActor
    func markRegisterProgress(_ progress: SetupRegisterTask) {
        registerProgress = progress
    }
        
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
        
    func handleFaceImage(_ image: CGImage) {}
    
    func clearImages() {
        faceImage = nil
        faceImages = []
    }
}
