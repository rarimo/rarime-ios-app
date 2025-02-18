import SwiftUI

struct V2NavBarView: View {
    @Binding var selectedTab: V2MainTabs

    var body: some View {
        HStack(spacing: 16) {
            ForEach(V2MainTabs.allCases, id: \.self) { item in
                V2NavBarTabItem(tab: item, isActive: selectedTab == item)
                    .onTapGesture {
                        selectedTab = item
                        FeedbackGenerator.shared.impact(.light)
                    }
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.baseWhite)
    }
}

struct V2NavBarTabItem: View {
    let tab: V2MainTabs
    let isActive: Bool
    
    var body: some View {
        Image(isActive ? tab.activeIconName : tab.iconName)
            .square(24)
            .frame(width: 48, height: 40)
            .background(isActive ? .baseBlack.opacity(0.03) : .clear)
            .foregroundStyle(isActive ? .baseBlack : .baseBlack.opacity(0.3))
            .cornerRadius(12)
    }
}


#Preview {
    V2NavBarView(selectedTab: .constant(.home))
}
