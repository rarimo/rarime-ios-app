//
//  EnablePasscodeView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 31.03.2024.
//

import SwiftUI

struct EnablePasscodeView: View {
    @EnvironmentObject var viewModel: AppView.ViewModel

    var body: some View {
        EnableLayoutView(
            icon: Icons.password,
            title: "Enable\nPasscode",
            description: "Enable Passcode Authentication",
            enableAction: { viewModel.enablePasscode("1234") },
            skipAction: { viewModel.skipPasscode() }
        )
    }
}

#Preview {
    EnablePasscodeView()
        .environmentObject(AppView.ViewModel())
}
