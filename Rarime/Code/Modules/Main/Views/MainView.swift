//
//  MainView.swift
//  Rarime
//
//  Created by Ivan Lele on 21.03.2024.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = MainTabs.home

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView().tag(MainTabs.home)
                    WalletView().tag(MainTabs.wallet)
                    RewardsView().tag(MainTabs.rewards)
                    CredentialsView().tag(MainTabs.credentials)
                    SettingsView().tag(MainTabs.settings)
                }
                .onAppear {
                    // Remove background from tab bar
                    let appearance = UITabBarAppearance()
                    appearance.configureWithTransparentBackground()
                    UITabBar.appearance().standardAppearance = appearance
                }
                TabBarView(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .tint(.textPrimary)
    }
}

#Preview {
    MainView()
}
