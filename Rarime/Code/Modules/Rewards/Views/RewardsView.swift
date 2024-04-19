import SwiftUI

struct RewardsView: View {
    var body: some View {
        MainViewLayout {
            Text("Rewards").subtitle2()
        }
    }
}

#Preview {
    RewardsView()
        .environmentObject(MainView.ViewModel())
}
