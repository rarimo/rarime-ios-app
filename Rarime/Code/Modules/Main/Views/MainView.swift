//
//  MainView.swift
//  Rarime
//
//  Created by Ivan Lele on 21.03.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    @State private var selectedTab = MainTabs.home

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    TabView(selection: $selectedTab) {
                        HomeView(onBalanceTap: { selectedTab = .wallet }).tag(MainTabs.home)
                        WalletView().tag(MainTabs.wallet)
                        RewardsView().tag(MainTabs.rewards)
                        CredentialsView().tag(MainTabs.credentials)
                        SettingsView()
                            .environmentObject(appViewModel)
                            .tag(MainTabs.settings)
                    }
                    .onAppear {
                        // Remove tab bar background
                        let appearance = UITabBarAppearance()
                        appearance.configureWithTransparentBackground()
                        UITabBar.appearance().standardAppearance = appearance
                    }
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
        .environmentObject(AppView.ViewModel())
}
