import SwiftUI

struct MainViewLayout<Content: View>: View {
    @EnvironmentObject var mainViewModel: MainView.ViewModel
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            TabBarView(selectedTab: $mainViewModel.selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainViewLayout {
        Rectangle().fill(.backgroundPrimary)
    }
    .environmentObject(MainView.ViewModel())
}
