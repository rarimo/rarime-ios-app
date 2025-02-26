import SwiftUI

struct V2NavBarView: View {
    @Binding var selectedTab: V2MainTabs
    @Binding var isQrCodeScanSheetShown: Bool

    var body: some View {
        HStack(spacing: 12) {
            ForEach(V2MainTabs.allCases, id: \.self) { item in
                V2NavBarTabItem(tab: item, isActive: selectedTab == item)
                    .onTapGesture {
                        if item == .scanQr {
                            isQrCodeScanSheetShown = true
                        } else {
                            selectedTab = item
                        }
                        FeedbackGenerator.shared.impact(.light)
                    }
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .bottom)
        .background(.bgBlur)
    }
}

struct V2NavBarTabItem: View {
    let tab: V2MainTabs
    let isActive: Bool
    
    var body: some View {
        Image(isActive ? tab.activeIconName : tab.iconName)
            .square(24)
            .frame(width: 48, height: 40)
            .background(isActive ? .bgComponentPrimary : .clear)
            .foregroundStyle(isActive ? .textPrimary : .textPlaceholder)
            .cornerRadius(12)
    }
}


#Preview {
    V2NavBarView(selectedTab: .constant(.home), isQrCodeScanSheetShown: .constant(false))
}
