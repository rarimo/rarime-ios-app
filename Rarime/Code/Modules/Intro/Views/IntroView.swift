import SwiftUI

private enum IdentityRoute: Hashable {
    case newIdentity, importIdentity
}

struct IntroView: View {
    var onFinish: () -> Void

    @State private var currentStep = IntroStep.welcome.rawValue
    @State private var path: [IdentityRoute] = []

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
                            onNext: { withAnimation { onFinish() } }
                        )
                    case .importIdentity:
                        // TODO: Implement import identity
                        Text("Import Identity")
                    }
                }
                .background(.backgroundPure)
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
                AppButton(text: "Create Account") {
                    path.append(.newIdentity)
                }
            } else {
                StepIndicator(steps: IntroStep.allCases.count, currentStep: currentStep)
                Spacer()
                AppButton(text: "Next", rightIcon: Icons.arrowRight, width: nil) {
                    currentStep += 1
                }
            }
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
    IntroView(onFinish: {})
}
