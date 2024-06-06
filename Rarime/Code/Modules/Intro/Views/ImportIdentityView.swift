//

import SwiftUI

struct ImportIdentityView: View {
    @EnvironmentObject private var userManager: UserManager
    
    var onNext: () -> Void
    var onBack: () -> Void
    
    @State private var privateKeyHex = ""
    @State private var isInvalidPrivateKey = false
    
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
                ).controlSize(.large)
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
            
            LoggerUtil.common.info("Identity was imported")
            
            onNext()
        } catch {
            LoggerUtil.common.error("failed to import identity")
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
        .environmentObject(UserManager.shared)
}
