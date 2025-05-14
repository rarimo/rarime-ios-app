import AVFoundation
import SwiftUI

class FaceCaptureSession: NSObject {
    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let systemPreferredCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private var sessionQueue = DispatchQueue(label: "video.face.session")
    
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    private var addToPreviewStream: ((CGImage) -> Void)?
        
    lazy var previewStream: AsyncStream<CGImage> = AsyncStream { continuation in
        addToPreviewStream = { cgImage in
            continuation.yield(cgImage)
        }
    }
    
    override init() {
        super.init()
        
        Task {
            do {
                try await configureSession()
            } catch {
                LoggerUtil.common.fault("Error configuring session: \(error, privacy: .public)")
            }
        }
    }
    
    private func configureSession() async throws {
        guard await isAuthorized, let systemPreferredCamera else { return }
        
        let deviceInput = try AVCaptureDeviceInput(device: systemPreferredCamera)
        
        defer {
            self.captureSession.commitConfiguration()
        }
            
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            
        guard captureSession.canAddInput(deviceInput) else {
            throw "Device input not added"
        }
            
        guard captureSession.canAddOutput(videoOutput) else {
            throw "Video output not added"
        }
            
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
        
        // Set frame rate to 21 FPS
        try systemPreferredCamera.lockForConfiguration()
        systemPreferredCamera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 21)
        systemPreferredCamera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 21)
        systemPreferredCamera.unlockForConfiguration()
    }

    public func startSession() async {
        guard await isAuthorized else { return }
        
        captureSession.startRunning()
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
}

extension FaceCaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let currentFrame = sampleBuffer.cgImage else {
            return
        }
        
        connection.videoOrientation = .portrait
        addToPreviewStream?(currentFrame)
    }
}
