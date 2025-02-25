import SwiftUI

private enum IdentityRoute: Hashable {
    case newIdentity, importIdentity
}

struct IntroView: View {
    var onFinish: () -> Void

    @State private var currentStep = IntroStep.welcome.rawValue
    @State private var showSheet = false
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
                        .navigationBarBackButtonHidden()
                    case .importIdentity:
                        ImportIdentityView(
                            onNext: { withAnimation { onFinish() } },
                            onBack: { path.removeLast() }
                        )
                        .navigationBarBackButtonHidden()
                    }
                }
                .background(.bgPure)
        }
    }

    var introContent: some View {
        VStack(alignment: .leading) {
            IntroStepView(step: .welcome)
            Spacer()
            VStack(spacing: 24) {
                introActions
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .padding(.horizontal, 24)
        }
    }

    var introActions: some View {
        AppButton(text: "Create Account") {
            showSheet = true
        }
        .controlSize(.large)
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

#Preview {
    IntroView(onFinish: {})
        .environmentObject(UserManager.shared)
}
