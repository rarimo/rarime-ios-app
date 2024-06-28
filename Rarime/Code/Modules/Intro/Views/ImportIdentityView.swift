import SwiftUI
import Alamofire

struct ImportIdentityView: View {
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var userManager: UserManager
    
    var onNext: () -> Void
    var onBack: () -> Void
    
    @State private var privateKeyHex = ""
    @State private var isInvalidPrivateKey = false
    @State private var isImporting = false
    
    var body: some View {
        IdentityStepLayoutView(
            title: "Import Identity" ,
            onBack: {
                userManager.user = nil
                onBack()
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
                        TextField(
                            "Private key",
                            text: $privateKeyHex,
                            prompt: isInvalidPrivateKey ? Text("Invalid private key").foregroundColor(.red) : nil
                        )
                        .onSubmit(importIdentity)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onTapGesture {
                            if isInvalidPrivateKey {
                                isInvalidPrivateKey = false
                            }
                        }
                    }
                }
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
                    privateKeyHex = ""
                    isInvalidPrivateKey = true
                    
                    return
                }
                
                guard let privateKey = Data(hex: privateKeyHex) else {
                    privateKeyHex = ""
                    isInvalidPrivateKey = true
                    
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
            
            userManager.user?.userReferalCode = "placeholder"
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
