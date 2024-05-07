import SwiftUI

struct CheckPassportView: View {
    private static let MAX_PASSCODE_ATTEMPTS = 5
    private static let BAN_TIME = 60 * 5
    
    @EnvironmentObject private var securityManager: SecurityManager
    
    @State private var passcode = ""
    @State private var errorMessage = ""
    
    @State private var failedAttempts = 0
    
    @State private var banTimeEnd = AppUserDefaults.shared.banTimeEnd 
    
    var body: some View {
        PasscodeView(
            passcode: $passcode,
            errorMessage: $errorMessage,
            title: "Enter passcode",
            onFill: handlePasscode,
            onClose: {},
            isClosable: false
        )
        .disabled(banTimeEnd != nil)
        .onAppear(perform: authByFaceID)
        .onAppear(perform: handleBanTime)
    }
    
    func authByFaceID() {
        if securityManager.faceIdState != .enabled {
            return
        }
        
        FaceIdAuth.shared.authenticate(
            onSuccess: {
                securityManager.isPasscodeCorrect = true
            }, onFailure: {
                FeedbackGenerator.shared.notify(.error)
            }, onNotAvailable: {}
        )
    }
    
    func handlePasscode() {
        if banTimeEnd != nil {
            return
        }
        
        if passcode != securityManager.passcode {
            errorMessage = "Passcode is incorrect"
            FeedbackGenerator.shared.notify(.error)
            
            failedAttempts += 1
            
            if failedAttempts >= CheckPassportView.MAX_PASSCODE_ATTEMPTS {
                let newBanTimeEnd = Date().addingTimeInterval(TimeInterval(CheckPassportView.BAN_TIME))
                
                
                AppUserDefaults.shared.banTimeEnd = newBanTimeEnd
                banTimeEnd = newBanTimeEnd
                
                handleBanTime()
                
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                passcode = ""
                errorMessage = ""
            }
            
            return
        }
        
        securityManager.isPasscodeCorrect = true
    }
    
    func handleBanTime() {
        guard let banTime = banTimeEnd else {
            return
        }
        
        errorMessage = "You are banned to " + banTime.formatted(date: .omitted, time: .standard)
        FeedbackGenerator.shared.notify(.error)
        
        Task { @MainActor in
            let banTimeEndInSecs = banTime.timeIntervalSince1970 - Date().timeIntervalSince1970
            
            try? await Task.sleep(nanoseconds: UInt64(banTimeEndInSecs) * NSEC_PER_SEC)
            
            while true {
                if Date() > banTime {
                    banTimeEnd = nil
                    AppUserDefaults.shared.banTimeEnd = nil
                    
                    passcode = ""
                    errorMessage = ""
                    
                    return
                }
                
                
            }
        }
    }
}

#Preview {
    CheckPassportView()
        .environmentObject(SecurityManager.shared)
}
