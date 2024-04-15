//
//  SettingsView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Settings").subtitle2()
            AppButton(text: "Back to Intro") {
                appViewModel.reset()
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    SettingsView()
}
