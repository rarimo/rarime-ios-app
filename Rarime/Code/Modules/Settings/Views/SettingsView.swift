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
            Button(action: { appViewModel.reset() }) {
                Text("Back to Intro").buttonMedium().frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    SettingsView()
}
