//
//  EnableFaceIdView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 31.03.2024.
//

import SwiftUI

struct EnableFaceIdView: View {
    @EnvironmentObject var viewModel: AppView.ViewModel

    var body: some View {
        EnableLayoutView(
            icon: Icons.userFocus,
            title: "Enable\nFace ID",
            description: "Enable Face ID Authentication",
            enableAction: { viewModel.enableFaceId() },
            skipAction: { viewModel.skipFaceId() }
        )
    }
}

#Preview {
    EnableFaceIdView()
        .environmentObject(AppView.ViewModel())
}
