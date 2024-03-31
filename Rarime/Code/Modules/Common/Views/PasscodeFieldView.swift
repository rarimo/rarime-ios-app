//
//  PasscodeFieldView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 31.03.2024.
//

import Combine
import SwiftUI

private enum FocusField: Hashable {
    case field
}

private let passcodeLength: Int = 4

struct PasscodeFieldView: View {
    @Binding var passcode: String
    @Binding var errorMessage: String
    var onFill: () -> Void

    @State var isFilled: Bool = false
    @FocusState private var focusField: FocusField?

    init(passcode: Binding<String>, errorMessage: Binding<String> = .constant(""), onFill: @escaping () -> Void = {}) {
        self._errorMessage = errorMessage
        self._passcode = passcode
        self.onFill = onFill
    }

    var body: some View {
        ZStack {
            textField
            passcodeView
        }
    }

    var textField: some View {
        TextField(String(""), text: $passcode)
            .frame(width: 0, height: 0)
            .keyboardType(.numberPad)
            .focused($focusField, equals: .field)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.focusField = .field
                }
            }
            .onReceive(Just(passcode)) { _ in
                if passcode.count > passcodeLength {
                    passcode = String(passcode.prefix(passcodeLength))
                }

                if passcode.count == passcodeLength && !isFilled {
                    isFilled = true
                    onFill()
                } else if passcode.count < passcodeLength {
                    isFilled = false
                    errorMessage = ""
                }
            }
    }

    var passcodeView: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0 ..< passcodeLength, id: \.self) { index in
                    ZStack {
                        Circle()
                            .frame(height: 16)
                            .foregroundColor(index < passcode.count ? errorMessage.isEmpty ? .primaryMain : .errorMain : .componentPrimary)
                    }
                    .padding(16)
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.errorMain)
            }
        }
    }
}

#Preview {
    VStack {
        PasscodeFieldView(passcode: .constant("123"))
        PasscodeFieldView(
            passcode: .constant("123"),
            errorMessage: .constant("Error message")
        )
    }
}
