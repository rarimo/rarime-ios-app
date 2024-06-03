import SwiftUI

struct VersionUpdateView: View {
    var body: some View {
        VStack {
            Text("The new version of the application is available in the App Store, it may contain critical improvements, so you have to download it")
                .multilineTextAlignment(.center)
                .bold()
                .frame(width: 300)
        }
    }
}

#Preview {
    VersionUpdateView()
}
