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
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        Text(banTimeEnd == nil ? "Enter Passcode" : "Account Locked")
                            .h4()
                            .foregroundStyle(.textPrimary)
                        Text(lockedMessage)
                            .body3()
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(minHeight: 40)
                    }
                    PasscodeFieldView(
                        passcode: $passcode,
                        errorMessage: $errorMessage,
                        isFaceIdEnabled: securityManager.faceIdState == .enabled,
                        onFill: handlePasscode,
                        onFaceIdClick: authByFaceID
                    )
                    .disabled(banTimeEnd != nil)
                }
                .padding(.top, 48)
                .padding(.bottom, 48)
                .padding(.horizontal, 8)
                .background(.backgroundPure)
                .clipShape(
                    .rect(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    )
                )
                Image(banTimeEnd == nil ? Icons.user : Icons.lock)
                    .iconLarge()
                    .padding(24)
                    .background(banTimeEnd == nil ? .primaryMain : .secondaryMain, in: Circle())
                    .foregroundStyle(banTimeEnd == nil ? .baseBlack : .baseWhite)
                    .overlay(Circle().stroke(.backgroundPure, lineWidth: 10))
                    .padding(.top, -36)
            }
            .padding(.top, 190)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPrimary)
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
