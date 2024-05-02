import SwiftUI

struct CheckPassportView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    
    @State private var passcode = ""
    @State private var errorMessage = ""
    
    var body: some View {
        PasscodeView(
            passcode: $passcode,
            errorMessage: $errorMessage,
            title: "Enter passcode",
            onFill: handlePasscode,
            onClose: {},
            isClosable: false
        )
        .onAppear(perform: authByFaceID)
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
        if passcode != securityManager.passcode {
            errorMessage = "Passcode is incorrect"
            FeedbackGenerator.shared.notify(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                passcode = ""
                errorMessage = ""
            }
            
            return
        }
        
        securityManager.isPasscodeCorrect = true
    }
}

#Preview {
    CheckPassportView()
        .environmentObject(SecurityManager.shared)
}
