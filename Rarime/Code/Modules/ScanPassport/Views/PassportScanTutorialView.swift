import SwiftUI
import AVKit

struct PassportScanTutorialButton: View {
    @State private var isTutorialPresented = false
    
    var body: some View {
        Button(action: { isTutorialPresented = true }) {
            HStack(spacing: 20) {
                ZStack {
                    Image(Images.passportTutorialThumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 56)
                    Image(Icons.play)
                        .iconSmall()
                        .foregroundStyle(.baseWhite)
                        .padding(8)
                        .background(.baseBlack, in: Circle())
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Play video tutorial")
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                    Text("Learn how to scan passport correctly")
                        .body4()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
            }
            .padding(12)
            .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 16))
        }
        .dynamicSheet(isPresented: $isTutorialPresented, fullScreen: true) {
            PassportScanTutorialView(onStart: { isTutorialPresented = false })
        }
    }
}

struct PassportScanTutorialView: View {
    let onStart: () -> Void
    
    @State private var currentStep = PassportTutorialStep.removeCase.rawValue
    
    var body: some View {
        TabView(selection: $currentStep) {
            ForEach(PassportTutorialStep.allCases, id: \.self) { step in
                PassportScanTutorialStep(
                    step: step,
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
    let action: () -> Void
    @Binding var currentStep: Int
    @State private var player: AVPlayer
    
    init(
        step: PassportTutorialStep,
        action: @escaping () -> Void,
        currentStep: Binding<Int>
    ) {
        self.step = step
        self.action = action
        self.player = AVPlayer(url: step.video)
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
            VideoPlayer(player: player)
                .disabled(true)
                .aspectRatio(362 / 404, contentMode: .fill)
                .frame(height: 404)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 14)
                .onAppear {
                    player.play()
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
                .onDisappear {
                    player.pause()
                }
            
            VStack(alignment: .leading, spacing: 16) {
                Text(step.title)
                    .h4()
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(step.text)
                    .body2()
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
                    AppButton(text: step.buttonText, rightIcon: Icons.arrowRight) {
                        action()
                    }
                } else {
                    StepIndicator(steps: PassportTutorialStep.allCases.count, currentStep: step.rawValue)
                    Spacer()
                    AppButton(text: step.buttonText, rightIcon: Icons.arrowRight, width: nil) {
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
}
