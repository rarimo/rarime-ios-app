import SwiftUI
import Alamofire

struct CreateIdentityIntroView: View {
#if DEVELOPMENT
    static let isImportJsonSupported = true
#else
    static let isImportJsonSupported = false
#endif
    
    let onStart: (Bool) -> Void
    
    @State private var termsChecked = false
    @State private var isImportJson = false

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Add a Document"),
                description: String(localized: "Create your digital identity"),
                icon: Image(Images.rewardCoin).square(110)
            ) {
                Text("Identity creation happens via a scan of your biometric passport.\n\nYour data never leaves the device or is shared with any third party. Proof of citizenship is generated locally using Zero-Knowledge technology.")
                    .body3()
                    .foregroundStyle(.textPrimary)
                InfoAlert(text: "If you lose access to the device or private keys, you won’t be able to claim future rewards using the same passport") {}
                if CreateIdentityIntroView.isImportJsonSupported {
                    HStack {
                        AppCheckbox(checked: $isImportJson)
                        Text("Use JSON file")
                            .body4()
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
            Spacer()
            HorizontalDivider()
            AirdropCheckboxView(checked: $termsChecked)
                .padding(.horizontal, 20)
            AppButton(text: "Continue", action: {
                onStart(isImportJson)
            })
            .controlSize(.large)
            .disabled(!termsChecked)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let userManager = UserManager.shared
    
    return CreateIdentityIntroView(onStart: { _ in })
        .environmentObject(ConfigManager())
        .onAppear {
            try? userManager.createNewUser()
        }
}

