import Combine
import Semaphore
import SwiftUI
import Vision

extension MRZScanView {
    class ViewModel: ObservableObject {
        @Published var currentFrame: CGImage?
        
        private let cameraManager = MRZCameraManager()
        
        var lastMRZAttemptDate = Date()
        
        private let semaphore = AsyncSemaphore(value: 1)
        
        var onMRZKey: (String) -> Void = { _ in }
        var onUSA: () -> Void = {}
        
        @Published var cameraTask: Task<Void, Never>? = nil
        
        func startScanning() {
            cameraTask = Task { await handleCameraPreviews() }
        }
        
        func stopScanning() {
            cameraTask?.cancel()
            
            cameraManager.stopSession()
        }
        
        func handleCameraPreviews() async {
            for await image in cameraManager.previewStream {
                Task { @MainActor in
                    currentFrame = image
                }
                
                Task { @MainActor in
                    do {
                        try await detectMRZ(image)
                    } catch {
                        LoggerUtil.common.error("Error detecting MRZ: \(error, privacy: .public)")
                    }
                }
            }
        }
        
        func detectMRZ(_ image: CGImage) async throws {
            await semaphore.wait()
            defer { semaphore.signal() }
            
            if lastMRZAttemptDate > Date().addingTimeInterval(-0.5) {
                return
            }
            
            defer {
                lastMRZAttemptDate = Date()
            }
            
            var recognizedTexts: [String] = []
            
            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
            
            let request = VNRecognizeTextRequest { request, _ in
                guard let result = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                
                // Extract the data
                let stringArray = result.compactMap { result in
                    result.topCandidates(1).first?.string
                }
                
                recognizedTexts.append(contentsOf: stringArray)
            }
            
            request.recognitionLevel = .accurate
            
            try requestHandler.perform([request])
            
            if !recognizedTexts.isEmpty {
                var nationality = ""
                var documentType: DocumentType? = nil
                var documentNumber = ""
                for text in recognizedTexts {
                    if !(text.count == 30 || text.count == 43 || text.count == 44) {
                        continue
                    }
                    
                    if let documentType {
                        switch documentType {
                        case .idCard:
                            readMRZFromIDCard(text, documentNumber, nationality)
                        case .passport:
                            readMRZFromPassport(text, nationality)
                        }
                        
                        return
                    } else {
                        if text.starts(with: "P<") {
                            documentType = .passport
                            
                            nationality = getNationality(text)
                            
                            continue
                        } else if text.starts(with: "ID") {
                            documentType = .idCard
                            
                            let documentNumberStartIndex = text.index(text.startIndex, offsetBy: 5)
                            let documentNumberEndIndex = text.index(text.startIndex, offsetBy: 14)
                            
                            documentNumber = String(text[documentNumberStartIndex...documentNumberEndIndex])
                            
                            nationality = getNationality(text)
                            
                            continue
                        }
                    }
                }
            }
        }
        
        func readMRZFromPassport(_ text: String, _ nationality: String) {
            let documentNumberStartIndex = text.index(text.startIndex, offsetBy: 0)
            let documentNumberEndIndex = text.index(text.startIndex, offsetBy: 9)
            
            let birthdayStartIndex = text.index(text.startIndex, offsetBy: 13)
            let birthdayEndIndex = text.index(text.startIndex, offsetBy: 19)
            
            let expirationStartIndex = text.index(text.startIndex, offsetBy: 21)
            let expirationEndIndex = text.index(text.startIndex, offsetBy: 27)
            
            let documentNumber = String(text[documentNumberStartIndex...documentNumberEndIndex])
            let birthday = String(text[birthdayStartIndex...birthdayEndIndex])
            let expiration = String(text[expirationStartIndex...expirationEndIndex])
                
            readMrzFromDocument(documentNumber, birthday, expiration, nationality)
        }
        
        func readMRZFromIDCard(_ text: String, _ documentNumber: String, _ nationality: String) {
            let birthdayStartIndex = text.index(text.startIndex, offsetBy: 0)
            let birthdayEndIndex = text.index(text.startIndex, offsetBy: 6)
            
            let expirationStartIndex = text.index(text.startIndex, offsetBy: 8)
            let expirationEndIndex = text.index(text.startIndex, offsetBy: 14)
            
            let birthday = String(text[birthdayStartIndex...birthdayEndIndex])
            let expiration = String(text[expirationStartIndex...expirationEndIndex])
            
            readMrzFromDocument(documentNumber, birthday, expiration, nationality)
        }
        
        func readMrzFromDocument(
            _ documentNumber: String,
            _ birthday: String,
            _ expiration: String,
            _ nationality: String
        ) {
            let mrzKey = "\(documentNumber+birthday+expiration)"
            
            let checkMrzKey = PassportUtils.getMRZKey(
                passportNumber: String(documentNumber.dropLast()),
                dateOfBirth: String(birthday.dropLast()),
                dateOfExpiry: String(expiration.dropLast())
            )
            
            if mrzKey == checkMrzKey {
                if nationality == "USA" {
                    onUSA()
                }
                
                onMRZKey(mrzKey)
                
                stopScanning()
            }
        }
        
        func getNationality(_ text: String) -> String {
            let nationalityStartIndex = text.index(text.startIndex, offsetBy: 2)
            let nationalityEndIndex = text.index(text.startIndex, offsetBy: 4)
            
            return String(text[nationalityStartIndex...nationalityEndIndex]).uppercased()
        }
    }
}

extension MRZScanView.ViewModel {
    enum DocumentType {
        case idCard, passport
    }
}
