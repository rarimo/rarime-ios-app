import SwiftUI

private enum IntroRoute: Hashable {
    case newIdentity, importIdentity
}

private struct AuthMethod: Identifiable, Hashable {
    var id: IntroRoute
    var name: String
    var icon: String
}

struct IntroView: View {
    var onFinish: () -> Void
    
    private let animationOffset: CGFloat = 64
    private let animationDelay: CGFloat = 0.4
    
    @State private var isInitialAnimationActive = true
    @State private var contentOpacity: Double = 0.0
    
    @State private var isNewIdentitySheetPresented = false
    @State private var isImportIdentitySheetPresented = false
    
    private var authMethods: [AuthMethod] {
        [
            AuthMethod(
                id: .newIdentity,
                name: String(localized: "Create new identity"),
                icon: Icons.addFill
            ),
            AuthMethod(
                id: .importIdentity,
                name: String(localized: "Re-activate old profile"),
                icon: Icons.shareForwardLine
            ),
        ]
    }

    var body: some View {
        content
            .background(.bgPrimary, ignoresSafeAreaEdges: .all)
            .dynamicSheet(isPresented: $isNewIdentitySheetPresented, fullScreen: true) {
                NewIdentityView(
                    onBack: { isNewIdentitySheetPresented = false },
                    onNext: { withAnimation { onFinish() } }
                )
            }
            .dynamicSheet(isPresented: $isImportIdentitySheetPresented, fullScreen: true) {
                ImportIdentityView(
                    onNext: { withAnimation { onFinish() } },
                    onBack: { isImportIdentitySheetPresented = false }
                )
            }
    }

    var content: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Spacer()
                Image(Icons.rarime)
                    .square(96)
                    .foregroundStyle(Gradients.gradientFirst)
                    .padding(.all, 44)
                    .background(.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 48))
                    .offset(y: isInitialAnimationActive ? 0 : (geometry.size.height / 2 - geometry.size.height * 0.7))
                Spacer()
                VStack(spacing: 8) {
                    Text("Welcome To")
                        .subtitle4()
                        .foregroundStyle(.textSecondary)
                    Text("RariMe")
                        .h1()
                        .foregroundStyle(.textPrimary)
                }
                .padding(.top, 28)
                .opacity(contentOpacity)
                .offset(y: isInitialAnimationActive ? animationOffset : 0)
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select an authorization method")
                        .body3()
                        .foregroundStyle(.textSecondary)
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(authMethods) { authMethod in
                            Button(action: {
                                onAuthMethodSelect(authMethod.id)
                            }) {
                                HStack(spacing: 16) {
                                    Image(authMethod.icon)
                                        .iconMedium()
                                        .foregroundStyle(.baseBlack)
                                        .padding(.all, 10)
                                        .background(Gradients.gradientFirst)
                                        .clipShape(Circle())
                                    Text(authMethod.name)
                                        .buttonLarge()
                                        .foregroundStyle(.textPrimary)
                                }
                            }
                            if authMethod.id != authMethods.last?.id {
                                HorizontalDivider()
                            }
                        }
                    }
                    .padding(.all, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.bgComponentPrimary, lineWidth: 1)
                    )
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .opacity(contentOpacity)
                .offset(y: isInitialAnimationActive ? animationOffset : 0)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                    withAnimation(.interpolatingSpring(stiffness: 44, damping: 10)) {
                        isInitialAnimationActive = false
                        contentOpacity = 1.0
                    }
                }
            }
        }
    }
    
    private func onAuthMethodSelect(_ route: IntroRoute) {
        switch route {
        case .newIdentity:
            isNewIdentitySheetPresented = true
        case .importIdentity:
            isImportIdentitySheetPresented = true
        }
    }
}

#Preview {
    IntroView(onFinish: {})
        .environmentObject(UserManager.shared)
}
