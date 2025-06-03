import SwiftUI

struct RecoveryMethodView: View {
    @EnvironmentObject private var userManager: UserManager

    var animation: Namespace.ID
    let onClose: () -> Void

    @State private var isMethodSheetPresented = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PullToCloseWrapperView(action: onClose) {
                ZStack(alignment: .top) {
                    Image(.recoveryShieldBg)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
                        mainSheetContent
                    }
                }
            }
            Button(action: onClose) {
                Image(.closeFill)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(10)
                    .background(.bgComponentPrimary, in: Circle())
            }
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var mainSheetContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Recovery")
                    .h1()
                    .foregroundStyle(.invertedDark)
                    .padding(.top, 12)
                Text("Method")
                    .additional1()
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Gradients.darkGreenText)
                Text("Set up a new way to recover your account")
                    .body4()
                    .foregroundStyle(.textSecondary)
                    .padding(.top, 12)
                Text("Forget traditional methods. Use something truly yours: a personal item, your face, or even a unique gesture. Security has never felt this natural.")
                    .body4()
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
            }
            HorizontalDivider()
            AppButton(text: "Choose your method", action: {
                isMethodSheetPresented = true
            })
            .controlSize(.large)
        }
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 8)
        .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
        .dynamicSheet(isPresented: $isMethodSheetPresented, fullScreen: true) {
            RecoveryMethodSelectionView(
                onClose: { isMethodSheetPresented = false }
            )
        }
    }
}

#Preview {
    RecoveryMethodView(animation: Namespace().wrappedValue, onClose: {})
        .environmentObject(UserManager())
}
