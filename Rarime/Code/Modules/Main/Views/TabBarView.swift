//
//  TabBarView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: MainTabs

    var body: some View {
        HStack {
            ForEach(MainTabs.allCases, id: \.self) { item in
                Button {
                    selectedTab = item
                } label: {
                    CustomTabItem(
                        icon: item.iconName,
                        activeIcon: item.activeIconName,
                        isActive: selectedTab == item
                    )
                }
            }
        }
        .padding(4)
        .background(.secondaryDark)
        .cornerRadius(1000)
        .padding(.vertical, 48)
    }
}

extension TabBarView {
    func CustomTabItem(icon: String, activeIcon: String, isActive: Bool) -> some View {
        Image(isActive ? activeIcon : icon)
            .iconMedium()
            .frame(width: 48, height: 48)
            .background(isActive ? .primaryMain : .secondaryDark)
            .foregroundStyle(isActive ? .baseBlack : .baseWhite.opacity(0.5))
            .cornerRadius(24)
    }
}

#Preview {
    TabBarView(selectedTab: .constant(.home))
}