import SwiftUI

struct V2MainViewLayout<Content: View>: View {
    @EnvironmentObject var mainViewModel: V2MainView.ViewModel
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0, content: {
                V2NavBarView(selectedTab: $mainViewModel.selectedTab)
            })
    }
}

#Preview {
    V2MainViewLayout {
        Rectangle().fill(.bgPrimary)
    }
    .environmentObject(V2MainView.ViewModel())
}
