//
//  EnablePasscodeView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 31.03.2024.
//

import SwiftUI

struct EnablePasscodeView: View {
    @EnvironmentObject var viewModel: AppView.ViewModel

    @State private var passcode = ""
    @State private var repeatPasscode = ""
    @State private var repeatPasscodeError = ""

    @State private var isPasscodeShown = false
    @State private var isRepeatPasscodeShown = false

    var body: some View {
        if isRepeatPasscodeShown {
            PasscodeView(
                passcode: $repeatPasscode,
                errorMessage: $repeatPasscodeError,
                title: "Repeat Passcode",
                onFill: {
                    if passcode == repeatPasscode {
                        viewModel.enablePasscode(passcode)
                    } else {
                        repeatPasscodeError = String(localized: "Passcodes do not match")
                    }
                },
                onClose: {
                    passcode = ""
                    repeatPasscode = ""
                    repeatPasscodeError = ""
                    isRepeatPasscodeShown = false
                }
            )
        } else if isPasscodeShown {
            PasscodeView(
                passcode: $passcode,
                title: "Enter Passcode",
                onFill: { isRepeatPasscodeShown = true },
                onClose: {
                    passcode = ""
                    isPasscodeShown = false
                }
            )
        } else {
            EnableLayoutView(
                icon: Icons.password,
                title: "Enable\nPasscode",
                description: "Enable Passcode Authentication",
                enableAction: { isPasscodeShown = true },
                skipAction: { viewModel.skipPasscode() }
            )
        }
    }
}

private struct PasscodeView: View {
    @Binding var passcode: String
    @Binding var errorMessage: String
    let title: LocalizedStringResource
    let onFill: () -> Void
    let onClose: () -> Void

    init(
        passcode: Binding<String>,
        errorMessage: Binding<String> = .constant(""),
        title: LocalizedStringResource,
        onFill: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self._passcode = passcode
        self._errorMessage = errorMessage
        self.title = title
        self.onFill = onFill
        self.onClose = onClose
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onClose) {
                Image(Icons.close)
                    .iconMedium()
                    .foregroundColor(.textPrimary)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
            }
            VStack(spacing: 100) {
                Text(title)
                    .h4()
                    .foregroundStyle(.textPrimary)
                VStack {
                    PasscodeFieldView(
                        passcode: $passcode,
                        errorMessage: $errorMessage,
                        onFill: onFill
                    )
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 120)
        }
        .background(.backgroundPure)
    }
}

#Preview {
    EnablePasscodeView()
        .environmentObject(AppView.ViewModel())
}
