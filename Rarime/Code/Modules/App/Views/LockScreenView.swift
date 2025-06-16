import SwiftUI

struct LockScreenView: View {
    private static let MAX_PASSCODE_ATTEMPTS = 5
    private static let BAN_TIME = 60 * 5
    
    @EnvironmentObject private var securityManager: SecurityManager
    
    @State private var passcode = ""
    @State private var errorMessage = ""
    @State private var lockedMessage = ""
    
    @State private var failedAttempts = 0
    
    @State private var banTimeEnd = AppUserDefaults.shared.banTimeEnd
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image(banTimeEnd == nil ? .user : .lock2Line)
                    .square(32)
                    .padding(16)
                    .background(.bgComponentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                VStack(spacing: 12) {
                    Text(banTimeEnd == nil ? "Enter Passcode" : "Account Locked")
                        .h2()
                        .foregroundStyle(.textPrimary)
                    Text(lockedMessage)
                        .body4()
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 40)
                }
                .padding(.top, 24)
                PasscodeFieldView(
                    passcode: $passcode,
                    errorMessage: $errorMessage,
                    isFaceIdEnabled: securityManager.faceIdState == .enabled,
                    onFill: handlePasscode,
                    onFaceIdClick: authByFaceID
                )
                .disabled(banTimeEnd != nil)
            }
            .padding(.top, 148)
            .padding(.bottom, 48)
            .padding(.horizontal, 8)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgPrimary)
        .onAppear(perform: authByFaceID)
        .onAppear(perform: handleBanTime)
    }
    
    func authByFaceID() {
        if securityManager.faceIdState != .enabled || banTimeEnd != nil {
            return
        }
        
        FaceIdAuth.shared.authenticate(
            onSuccess: {
                DispatchQueue.main.async {
                    securityManager.isPasscodeCorrect = true
                }
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
            failedAttempts += 1
            errorMessage = String(localized: "Failed, \(LockScreenView.MAX_PASSCODE_ATTEMPTS - failedAttempts) attempts left")
            FeedbackGenerator.shared.notify(.error)
            
            if failedAttempts >= LockScreenView.MAX_PASSCODE_ATTEMPTS {
                let newBanTimeEnd = Date().addingTimeInterval(TimeInterval(LockScreenView.BAN_TIME))
                
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
        
        FeedbackGenerator.shared.notify(.error)
        updateLockedMessage()
        
        Task { @MainActor in
            var banTimeEndInSecs = banTime.timeIntervalSince1970 - Date().timeIntervalSince1970
            
            if banTimeEndInSecs < 0 {
                banTimeEndInSecs = 0
            }
            
            try? await Task.sleep(nanoseconds: UInt64(banTimeEndInSecs) * NSEC_PER_SEC)
            
            while true {
                if Date() > banTime {
                    banTimeEnd = nil
                    AppUserDefaults.shared.banTimeEnd = nil
                    
                    passcode = ""
                    errorMessage = ""
                    lockedMessage = ""
                    failedAttempts = 0
                    
                    return
                }
            }
        }
    }
    
    func updateLockedMessage() {
        guard let banTime = banTimeEnd else {
            return
        }
    
        Task { @MainActor in
            while banTime > Date() {
                lockedMessage = String(localized: "You entered wrong passcode.\nLoading time: \(timeRemaining(to: banTime))")
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
            }
            
            lockedMessage = ""
        }
    }
}

private func timeRemaining(to futureDate: Date) -> String {
    let currentDate = Date()
    let interval = futureDate.timeIntervalSince(currentDate)
    
    let minutes = Int(interval) / 60
    let seconds = Int(interval) % 60
    
    return String(localized: "\(minutes)m \(seconds)s")
}

#Preview {
    LockScreenView()
        .environmentObject(SecurityManager.shared)
}
