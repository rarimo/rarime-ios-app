//
//  AppView.swift
//  Rarime
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            if viewModel.isFaceIdSet {
                MainView()
            } else if viewModel.isPasscodeSet {
                EnableFaceIdView()
            } else if viewModel.isIntroFinished {
                EnablePasscodeView()
            } else {
                IntroView()
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
}
