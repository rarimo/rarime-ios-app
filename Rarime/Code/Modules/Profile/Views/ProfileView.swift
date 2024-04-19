import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel

    var body: some View {
        MainViewLayout {
            VStack(spacing: 24) {
                Text("Profile").subtitle2()
                AppButton(text: "Back to Intro") {
                    appViewModel.reset()
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppView.ViewModel())
        .environmentObject(MainView.ViewModel())
}
