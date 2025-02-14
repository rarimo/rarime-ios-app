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
        .padding(.vertical, 8)
    }
}

struct V2NavBarTabItem: View {
    let tab: V2MainTabs
    let isActive: Bool
    
    private var backgroundColor: Color {
        tab == .scanQr ? .baseBlack : .clear
    }
        
    private var activeBackgroundColor: Color {
        tab == .scanQr ? .baseBlack : .baseBlack.opacity(0.03)
    }

    private var foregroundColor: Color {
        tab == .scanQr ? .baseWhite : .baseBlack.opacity(0.3)
    }
    
    private var activeForegroundColor: Color {
        tab == .scanQr ? .baseWhite : .baseBlack
    }
    
    var body: some View {
        Image(isActive ? tab.activeIconName : tab.iconName)
            .square(24)
            .frame(width: 48, height: 40)
            .background(isActive ? activeBackgroundColor : backgroundColor)
            .foregroundStyle(isActive ? activeForegroundColor : foregroundColor)
            .cornerRadius(12)
    }
}


#Preview {
    V2NavBarView(selectedTab: .constant(.home))
}
