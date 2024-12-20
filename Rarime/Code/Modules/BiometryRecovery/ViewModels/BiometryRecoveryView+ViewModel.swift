import SwiftUI

enum BiometryRecoveryProgress: Int {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case overridingAccess = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKMK"
        case .overridingAccess: return "Overriding access"
        }
    }
}

extension BiometryRecoveryView {
    class ViewModel: ObservableObject {
        @Published var currentFrame: CGImage?
        @Published var faceImage: UIImage?
        
        private let cameraManager = BiomatryCaptureSession()
        
        @Published var cameraTask: Task<Void, Never>? = nil
        
        @Published var loadingProgress = 0.0
        
        @Published var recoveryProgress: [BiometryRecoveryProgress] = []
        
        func markRecoveryProgress(_ progress: BiometryRecoveryProgress) {
            if recoveryProgress.count < progress.rawValue {
                for _ in recoveryProgress.count..<progress.rawValue {
                    recoveryProgress.append(progress)
                }
            }
            
            recoveryProgress.append(progress)
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
        
        func handleFaceImage(_ image: CGImage) {
            Task { @MainActor in
                do {
                    if faceImage != nil {
                        return
                    }
                    
                    let faceImage = try ZKFaceManager.shared.extractFaceFromImage(UIImage(cgImage: image))
                    guard let faceImage = faceImage else {
                        if loadingProgress > 0 {
                            loadingProgress -= 0.01
                        }
                        
                        return
                    }
                    
                    if loadingProgress >= 1 {
                        self.faceImage = faceImage
                        
                        return
                    }
                    
                    loadingProgress += 0.01
                } catch {
                    LoggerUtil.common.error("Error extracting face: \(error)")
                }
            }
        }
        
        func recoverByBiometry(_ image: UIImage) {
            Task { @MainActor in
                do {
                    let (_, grayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(image)

                    let computableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(grayscalePixelsData)

                    let features = ZKFaceManager.shared.extractFeaturesFromComputableModel(computableModel)

                    LoggerUtil.common.debug("Image processing finished: \(features.json.utf8)")

                    let inputs = CircuitBuilderManager.shared.fisherFaceCircuit.buildInputs(computableModel, features)

                    let thread = Thread {
                        do {
                            let wtns = try ZKUtils.calcWtnsFisherface(inputs.json)

                            let (proofJson, pubSignalsJson) = try ZKUtils.groth16Fisherface(wtns)

                            let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
                            let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)

                            let zkProof = ZkProof(proof: proof, pubSignals: pubSignals)

                            LoggerUtil.common.debug("zkProof: \(zkProof.json.utf8)")
                        } catch {
                            LoggerUtil.common.debug("error: \(error)")
                        }
                    }

                    thread.stackSize = 100 * 1024 * 1024

                    thread.start()
                } catch {
                    LoggerUtil.common.error("failed to recover by biometry: \(error)")
                }
            }
        }
    }
}
