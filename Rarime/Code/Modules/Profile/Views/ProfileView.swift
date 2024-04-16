//
//  ProfileView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 15.04.2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Profile").subtitle2()
            AppButton(text: "Back to Intro") {
                appViewModel.reset()
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileView()
}
