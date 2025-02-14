import SwiftUI

struct V2MainViewLayout<Content: View>: View {
    @EnvironmentObject var mainViewModel: V2MainView.ViewModel
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        V2NavBarView(selectedTab: $mainViewModel.selectedTab)
    }
}

#Preview {
    V2MainViewLayout {
        Rectangle().fill(.backgroundPrimary)
    }
    .environmentObject(V2MainView.ViewModel())
}
