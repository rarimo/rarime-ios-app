//
//  IntroView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import SwiftUI

private enum IdentityRoute: Hashable {
    case newIdentity, verifyIdentity, importIdentity
}

struct IntroView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    @State private var currentStep = IntroStep.welcome.rawValue
    @State private var showSheet = false
    @State private var path = [IdentityRoute]()

    var isLastStep: Bool {
        currentStep == IntroStep.allCases.count - 1
    }

    var body: some View {
        NavigationStack(path: $path) {
            introContent
                .navigationDestination(for: IdentityRoute.self) { route in
                    switch route {
                    case .newIdentity:
                        NewIdentityView(
                            onBack: { path.removeLast() },
                            onNext: { path.append(.verifyIdentity) }
                        )
                    case .verifyIdentity:
                        VerifyIdentityView(
                            onBack: { path.removeLast() },
                            onNext: { withAnimation { appViewModel.finishIntro() } }
                        )
                    case .importIdentity:
                        // TODO: Implement import identity
                        Text("Import Identity")
                    }
                }
                .background(.backgroundPrimary)
        }
    }

    var introContent: some View {
        VStack(alignment: .leading) {
            introHeader
            TabView(selection: $currentStep) {
                ForEach(IntroStep.allCases, id: \.self) { item in
                    IntroStepView(step: item)
                        .tag(item.rawValue)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
            Spacer()
            VStack(spacing: 24) {
                HorizontalDivider()
                introActions
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .padding(.horizontal, 24)
        }
    }

    var introHeader: some View {
        HStack {
            Spacer()
            Button(action: { currentStep = IntroStep.allCases.count - 1 }) {
                Text("Skip")
                    .buttonMedium()
                    .foregroundStyle(.textSecondary)
            }
            .opacity(isLastStep ? 0 : 1)
        }
        .padding(.top, 20)
        .padding(.trailing, 24)
    }

    var introActions: some View {
        HStack {
            if isLastStep {
                Button(action: { showSheet.toggle() }) {
                    Text("Get Started")
                        .buttonMedium()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                StepIndicator(steps: IntroStep.allCases.count, currentStep: currentStep)
                Spacer()
                Button(action: { currentStep += 1 }) {
                    HStack(spacing: 8) {
                        Text("Next").buttonMedium()
                        Image(Icons.arrowRight).iconMedium()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .dynamicSheet(isPresented: $showSheet) {
            GetStartedView(
                onCreate: {
                    showSheet.toggle()
                    path.append(.newIdentity)
                },
                onImport: {
                    showSheet.toggle()
                    path.append(.importIdentity)
                }
            )
            .padding(.bottom, 24)
        }
    }
}

private struct StepIndicator: View {
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
