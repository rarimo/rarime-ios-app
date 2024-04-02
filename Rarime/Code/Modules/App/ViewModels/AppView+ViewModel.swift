//
//  AppView+ViewModel.swift
//  Rarime
//
//  Created by Ivan Lele on 19.03.2024.
//

import SwiftUI

extension AppView {
    class ViewModel: ObservableObject {
        let config: Config
        @Published var isIntroFinished = true

        @Published var isPasscodeSet = true
        @Published var passcode = ""

        @Published var isFaceIdSet = true
        @Published var isFaceIdEnabled = false

        init() {
            do {
                config = try Config()
            } catch {
                fatalError("AppViewModel error: \(error)")
            }
        }

        func finishIntro() {
            isIntroFinished = true
        }

        func enablePasscode(_ newPasscode: String) {
            passcode = newPasscode
            isPasscodeSet = true
        }

        func skipPasscode() {
            isPasscodeSet = true
        }

        func enableFaceId() {
            isFaceIdSet = true
            isFaceIdEnabled = true
        }

        func skipFaceId() {
            isFaceIdSet = true
            isFaceIdEnabled = false
        }

        func reset() {
            isIntroFinished = false
            isPasscodeSet = false
            passcode = ""
            isFaceIdSet = false
            isFaceIdEnabled = false
        }
    }
}
