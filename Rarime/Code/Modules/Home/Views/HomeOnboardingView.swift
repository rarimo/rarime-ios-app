import SwiftUI

private enum HomeOnboardingStep: Int, CaseIterable {
    case welcome, privacy, identity, widgets

    var title: String {
        switch self {
        case .welcome: String(localized: "Welcome!")
        case .privacy: String(localized: "Privacy")
        case .identity: String(localized: "Managing identity")
        case .widgets: String(localized: "Add widgets")
        }
    }

    var text: String {
        switch self {
        case .welcome: String(localized: "This app is where you privately store your digital identities, enabling you to go incognito across the web")
        case .privacy: String(localized: "No one can trace your actions\nNo system can connect the dots\nNo data ever leaves your phone")
        case .identity: String(localized: "Rarimo lets you prove your identity - without giving anything away")
        case .widgets: String(localized: "Add different type of applications that you can intersect with anonymously")
        }
    }

    var image: ImageResource {
        switch self {
        case .welcome: .introWelcome
        case .privacy: .introPrivacy
        case .identity: .introIdentity
        case .widgets: .introWidgets
        }
    }
}

struct HomeOnboardingView: View {
    let isPresented: Bool
    let onComplete: () -> Void

    @State private var currentStepIndex = HomeOnboardingStep.welcome.rawValue

    var isLastStep: Bool {
        currentStepIndex == HomeOnboardingStep.allCases.count - 1
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.additionalPopupBackground
                .opacity(isPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isPresented)
                .ignoresSafeArea()
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    TabView(selection: $currentStepIndex) {
                        ForEach(HomeOnboardingStep.allCases, id: \.self) { item in
                            StepView(step: item)
                                .tag(item.rawValue)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.25), value: currentStepIndex)
                    .frame(maxHeight: 440)
                    VStack(spacing: 32) {
                        HorizontalDivider()
                        if isLastStep {
                            AppButton(
                                text: "Explore Apps",
                                action: { withAnimation { onComplete() } }
                            )
                        } else {
                            HStack {
                                HorizontalStepIndicator(
                                    steps: HomeOnboardingStep.allCases.count,
                                    currentStep: currentStepIndex
                                )
                                .animation(.easeInOut(duration: 0.25), value: currentStepIndex)
                                Spacer()
                                AppButton(
                                    text: "Next",
                                    rightIcon: .arrowRight,
                                    width: 60,
                                    action: { currentStepIndex += 1 }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
                .background(.bgSurface1)
                .clipShape(RoundedRectangle(cornerRadius: 32))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 4)
            .offset(y: isPresented ? 0 : 700)
            .animation(.interpolatingSpring(stiffness: 300, damping: 50), value: isPresented)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct StepView: View {
    let step: HomeOnboardingStep

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ZStack(alignment: .topLeading) {
                Image(step.image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 287)
                Image(.rarime)
                    .iconLarge()
                    .foregroundStyle(.textPrimary)
                    .padding(8)
                    .background(.bgComponentBasePrimary, in: Circle())
                    .padding(24)
            }
            VStack(alignment: .leading, spacing: 16) {
                Text(step.title)
                    .h2()
                    .foregroundStyle(.textPrimary)
                Text(step.text)
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .frame(height: 68, alignment: .top)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    HomeOnboardingView(isPresented: true, onComplete: {})
}
