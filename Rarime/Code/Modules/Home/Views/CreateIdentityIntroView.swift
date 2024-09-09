import Alamofire
import SwiftUI

struct CreateIdentityIntroView: View {
    let onStart: () -> Void

    @State private var termsChecked = false

    var body: some View {
        VStack(spacing: 16) {}
    }
}

#Preview {
    let userManager = UserManager.shared

    return CreateIdentityIntroView(onStart: {})
        .environmentObject(ConfigManager())
        .onAppear {
            try? userManager.createNewUser()
        }
}
