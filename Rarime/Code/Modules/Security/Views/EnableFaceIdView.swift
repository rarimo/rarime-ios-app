//
//  EnableFaceIdView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 31.03.2024.
//

import SwiftUI

private enum FaceIdAuthError: Error {
    case notAvailable
    case failed
}

struct EnableFaceIdView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    @State private var isAlertShown = false
    @State private var isNotAvailableError = false

    var body: some View {
        EnableLayoutView(
            icon: Icons.userFocus,
            title: "Enable\nFace ID",
            description: "Enable Face ID Authentication",
            enableAction: {
                FaceIdAuth.shared.authenticate(
                    onSuccess: { withAnimation { appViewModel.enableFaceId() } },
                    onFailure: {
                        isNotAvailableError = false
                        isAlertShown = true

                    },
                    onNotAvailable: {
                        isNotAvailableError = false
                        isAlertShown = true
                    }
                )
            },
            skipAction: { withAnimation { appViewModel.skipFaceId() } }
        )
        .alert(isPresented: $isAlertShown) {
            Alert(
                title: isNotAvailableError
                    ? Text("Face ID Disabled")
                    : Text("Authentication Failed"),
                message: isNotAvailableError
                    ? Text("Enable Face ID in Settings > Rarime.")
                    : Text("Could not authenticate with Face ID. Please try again."),
                dismissButton: .default(Text("Close"))
            )
        }
    }
}

#Preview {
    EnableFaceIdView()
        .environmentObject(AppView.ViewModel())
}
