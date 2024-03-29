//
//  IntroView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import SwiftUI

enum IntroStep: Int, CaseIterable {
    case welcome, identity, privacy, rewards

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .identity: return "Plug your identity"
        case .privacy: return "Use them"
        case .rewards: return "Get rewarded"
        }
    }

    var text: String {
        switch self {
        case .welcome: return "This is an app where your digital identity lives and enables you to connect with rest of the web in a fully private mode"
        case .identity: return "Convert existing identity documents into anonymous credentials"
        case .privacy: return "Login and access special parts of the web"
        case .rewards: return "Create a profile, add various credentials, and invite others to earn rewards in the process"
        }
    }

    var image: String {
        switch self {
        case .welcome: return "IntroApp"
        case .identity: return "IntroIdentity"
        case .privacy: return "IntroPrivacy"
        case .rewards: return "IntroGifts"
        }
    }
}

class CurrentStep: ObservableObject {
    @Published var index = 0
}

struct IntroView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    @StateObject var currentStep = CurrentStep()
    @State private var showSheet = false

    var isLastStep: Bool {
        currentStep.index == IntroStep.allCases.count - 1
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: { currentStep.index = IntroStep.allCases.count - 1 }) {
                    Text("Skip")
                        .buttonMedium()
                        .foregroundStyle(.textSecondary)
                }
                .opacity(isLastStep ? 0 : 1)
            }
            .padding(.top, 20)
            .padding(.trailing, 24)
            TabView(selection: $currentStep.index) {
                ForEach(IntroStep.allCases, id: \.self) { item in
                    IntroStepView(step: item)
                        .tag(item.rawValue)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep.index)
            Spacer()
            VStack(spacing: 24) {
                HorizontalDivider()
                HStack {
                    if isLastStep {
                        Button(action: { appViewModel.finishIntro() }) {
                            Text("Get Started").buttonMedium().frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryContainedButtonStyle())
                        .sheet(isPresented: $showSheet) {
                            Text("Sheet")
                                .presentationDetents([.height(200), .medium])
                                .presentationDragIndicator(.hidden)
                        }
                    } else {
                        StepIndicator(steps: IntroStep.allCases.count, currentStep: currentStep.index)
                        Spacer()
                        Button(action: { currentStep.index += 1 }) {
                            HStack(spacing: 8) {
                                Text("Next").buttonMedium()
                                Image(Icons.arrowRight).iconMedium()
                            }
                        }
                        .buttonStyle(PrimaryContainedButtonStyle())
                    }
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .padding(.horizontal, 24)
        }
    }
}

struct StepIndicator: View {
    let steps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index == currentStep ? .primaryMain : .componentPrimary)
                    .frame(width: index == currentStep ? 16 : 8, height: 8)
            }
        }
    }
}

#Preview {
    IntroView()
        .environmentObject(AppView.ViewModel())
}
