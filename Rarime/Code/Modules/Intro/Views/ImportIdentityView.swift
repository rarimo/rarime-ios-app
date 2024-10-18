import SwiftUI
import Alamofire

struct ImportIdentityView: View {
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var userManager: UserManager
    
    var onNext: () -> Void
    var onBack: () -> Void
    
    @State private var privateKeyHex = ""
    @State private var privateKeyHexError = ""
    
    @State private var isManualBackup = false
    @State private var isImporting = false
    
    var body: some View {
        if isManualBackup {
            manualImportView
        } else {
            backupView
        }
    }
    
    var manualImportView: some View {
        IdentityStepLayoutView(
            title: "Import Identity" ,
            onBack: {
                userManager.user = nil
                isManualBackup = false
            },
            nextButton: {
                AppButton(
                    text: "Continue",
                    rightIcon: Icons.arrowRight,
                    action: importIdentity
                )
                .controlSize(.large)
                .disabled(isImporting)
            }
        ) {
            VStack {
                CardContainer {
                    VStack(spacing: 20) {
                        AppTextField(
                            text: $privateKeyHex,
                            errorMessage: $privateKeyHexError,
                            placeholder: String(localized: "Your private key")
                        )
                        .onSubmit(importIdentity)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isImporting)
                    }
                }
            }
        }
    }
    
    var backupView: some View {
        ZStack(alignment: .topLeading) {
            Button(action: onBack) {
                Image(Icons.arrowLeft)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            VStack(spacing: 32) {
                VStack {
                    Image(Icons.cloud)
                        .square(72)
                        .foregroundStyle(.primaryDarker)
                }
                .padding(40)
                .background(.primaryLighter)
                .clipShape(Circle())
                VStack(spacing: 12) {
                    Text("Restore your account")
                        .h4()
                        .foregroundStyle(.textPrimary)
                    Text("You can restore your account using your iCloud backup or private key")
                        .body2()
                        .foregroundStyle(.textSecondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                Spacer()
                VStack(spacing: 16) {
                    HorizontalDivider()
                    VStack(spacing: 8) {
                        AppButton(
                            text: "Restore with iCloud",
                            action: restoreFromICloud
                        )
                        .controlSize(.large)
                        .disabled(isImporting)
                        AppButton(
                            variant: .tertiary,
                            text: "Restore manually",
                            action: { isManualBackup = true }
                        )
                        .controlSize(.large)
                        .disabled(isImporting)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
            .padding(.bottom, 16)
        }
        .background(.backgroundPure)
    }
    
    func restoreFromICloud() {
        isImporting = true
        
        Task { @MainActor in
            defer {
                self.isImporting = false
            }
            
            do {
                let isICloudAvailable = try await CloudStorage.shared.isICloudAvailable()
                if !isICloudAvailable {
                    AlertManager.shared.emitError(.unknown(String(localized: "iCloud is not available")))
                    
                    return
                }
                
                userManager.user = try await User.loadFromCloud()
                
                if userManager.user == nil {
                    AlertManager.shared.emitError(.unknown(String(localized: "No backup found in iCloud")))
                    
                    return
                }
                
                try userManager.user?.save()
                
                try await setReferralCodeIfUserHasPointsBalance()
                
                LoggerUtil.common.info("Identity was imported")
                
                onNext()
            } catch {
                LoggerUtil.common.error("Failed to restore from iCloud: \(error, privacy: .public)")
            }
        }
    }
    
    func importIdentity() {
        self.isImporting = true
        
        Task { @MainActor in
            defer {
                self.isImporting = false
            }
            
            do {
                if !(try isValidPrivateKey(privateKeyHex)) {
                    privateKeyHexError = String(localized: "Invalid private key")
                    return
                }
                
                guard let privateKey = Data(hex: privateKeyHex) else {
                    privateKeyHexError = String(localized: "Invalid private key")
                    return
                }
                
                try userManager.createFromSecretKey(privateKey)
                try userManager.user?.save()
                
                try await setReferralCodeIfUserHasPointsBalance()
                
                LoggerUtil.common.info("Identity was imported")
                
                onNext()
            } catch {
                LoggerUtil.common.error("failed to import identity: \(error, privacy: .public)")
            }
        }
    }
    
    func setReferralCodeIfUserHasPointsBalance() async throws {
        do {
            guard let user = userManager.user else { throw "failed to get user" }
            
            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
            
            let points = Points(ConfigManager.shared.api.pointsServiceURL)
            let _ = try await points.getPointsBalance(accessJwt)
            
            LoggerUtil.common.info("User has points balance, setting referral code")
            
            userManager.user?.userReferralCode = "placeholder"
        } catch {
            guard let error = error as? AFError else { throw error }
            
            let openApiHttpCode = try error.retriveOpenApiHttpCode()
            
            if openApiHttpCode == HTTPStatusCode.notFound.rawValue {
                LoggerUtil.common.info("User has no points balance")
                
                return
            }
            
            throw error
        }
    }
}

fileprivate func isValidPrivateKey(_ privateKey: String) throws -> Bool {
    let regex = try NSRegularExpression(
        pattern: "^[0-9a-fA-F]{64}$",
        options: .caseInsensitive
    )
    
    return regex.firstMatch(
        in: privateKey,
        options: [],
        range: NSRange(location: 0, length: privateKey.utf16.count)
    ) != nil
}

#Preview {
    ImportIdentityView(onNext: {}, onBack: {})
        .environmentObject(DecentralizedAuthManager.shared)
        .environmentObject(UserManager.shared)
}
