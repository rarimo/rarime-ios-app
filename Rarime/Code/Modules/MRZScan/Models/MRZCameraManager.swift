import AVFoundation
import Foundation

class MRZCameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let systemPreferredCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    private var sessionQueue = DispatchQueue(label: "video.mrz.session")

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
                await startSession()
            } catch {
                LoggerUtil.common.fault("Error configuring session: \(error, privacy: .public)")
            }
        }
    }
    
    private func configureSession() async throws {
        guard await isAuthorized, let systemPreferredCamera else { return }
        
        try systemPreferredCamera.lockForConfiguration()
        systemPreferredCamera.focusMode = .continuousAutoFocus
        systemPreferredCamera.unlockForConfiguration()
        
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
    }

    private func startSession() async {
        guard await isAuthorized else { return }
        
        captureSession.startRunning()
    }
}

extension MRZCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
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
