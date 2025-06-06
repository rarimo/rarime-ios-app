import SwiftUI

struct PassportScanTutorialButton: View {
    @State private var isTutorialPresented = false
    
    var body: some View {
        Button(action: { isTutorialPresented = true }) {
            HStack(spacing: 20) {
                ZStack {
                    Image(.passportTutorialThumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 56)
                    Image(.play)
                        .iconSmall()
                        .foregroundStyle(.baseWhite)
                        .padding(8)
                        .background(.baseBlack, in: Circle())
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Play video tutorial")
                        .subtitle6()
                        .foregroundStyle(.textPrimary)
                    Text("Learn how to scan passport correctly")
                        .body5()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
            }
            .padding(12)
            .background(.bgComponentPrimary, in: RoundedRectangle(cornerRadius: 16))
        }
        .dynamicSheet(isPresented: $isTutorialPresented, fullScreen: true) {
            PassportScanTutorialView(onStart: { isTutorialPresented = false })
        }
    }
}

struct PassportScanTutorialView: View {
    @EnvironmentObject private var passportViewModel: PassportViewModel
    
    let onStart: () -> Void
    
    @State private var currentStep = PassportTutorialStep.removeCase.rawValue
    
    var body: some View {
        TabView(selection: $currentStep) {
            ForEach(PassportTutorialStep.allCases, id: \.self) { step in
                PassportScanTutorialStep(
                    step: step,
                    isUSA: passportViewModel.isUSA,
                    action: onStart,
                    currentStep: $currentStep
                )
                .tag(step.rawValue)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentStep)
    }
}

private struct PassportScanTutorialStep: View {
    let step: PassportTutorialStep
    let isUSA: Bool
    let action: () -> Void
    @Binding var currentStep: Int
    
    init(
        step: PassportTutorialStep,
        isUSA: Bool = false,
        action: @escaping () -> Void,
        currentStep: Binding<Int>
    ) {
        self.step = step
        self.isUSA = isUSA
        self.action = action
        self._currentStep = currentStep
    }
    
    private var isLastStep: Bool {
        step == PassportTutorialStep.allCases.last
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    var body: some View {
        VStack(spacing: 32) {
            LoopVideoPlayer(url: step.video(isUSA))
                .aspectRatio(362 / 404, contentMode: .fill)
                .frame(height: 404)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 14)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(step.title)
                    .h2()
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(step.text)
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: 100)
            Spacer()
            HorizontalDivider()
            HStack {
                if isLastStep {
                    AppButton(text: step.buttonText, rightIcon: .arrowRight) {
                        action()
                    }
                } else {
                    HorizontalStepIndicator(steps: PassportTutorialStep.allCases.count, currentStep: step.rawValue)
                    Spacer()
                    AppButton(text: step.buttonText, rightIcon: .arrowRight, width: nil) {
                        currentStep += 1
                    }
                }
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 16)
        .padding(.horizontal, 24)
    }
}

#Preview {
    PassportScanTutorialButton()
        .environmentObject(PassportViewModel())
}
