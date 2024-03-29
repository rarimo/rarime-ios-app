//
//  GetStartedView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import Foundation
import SwiftUI

struct GetStartedView: View {
    let onCreate: () -> Void
    let onImport: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Get Started").h5().foregroundStyle(.textPrimary)
                Text("Select Authorisation Method").body2().foregroundStyle(.textSecondary)
            }
            VStack {
                GetStartedButton(
                    title: "Create new Identity",
                    text: "Description text here",
                    icon: Icons.userPlus,
                    action: onCreate
                )
                GetStartedButton(
                    title: "Import from MetaMask Snap",
                    text: "Description text here",
                    icon: Icons.metamask,
                    action: onImport
                )
            }
        }
        .padding(.horizontal, 24)
    }
}

private struct GetStartedButton: View {
    let title: LocalizedStringResource
    let text: LocalizedStringResource
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack {
                    Image(icon).iconMedium().foregroundStyle(.textPrimary)
                }
                .padding(10)
                .background(.backgroundPure)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).buttonMedium().foregroundStyle(.textPrimary)
                    Text(text).body4().foregroundStyle(.textSecondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    GetStartedView(
        onCreate: {},
        onImport: {}
    )
}
