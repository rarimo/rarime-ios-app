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
    
    @State private var currentStep = PassportScanStep.scanYourPassport.rawValue
    
    var body: some View {
        TabView(selection: $currentStep) {
            ForEach(PassportScanStep.allCases, id: \.self) { item in
                PassportScanTutorialStep(
                    title: item.title,
                    description: item.text,
                    videoURL: item.video,
                    actionText: item.buttonText,
                    action: onStart,
                    currentStep: $currentStep
                )
                .tag(item.rawValue)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentStep)
    }
}

private struct PassportScanTutorialStep: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let videoURL: URL
    let actionText: LocalizedStringResource
    let action: () -> Void
    @Binding var currentStep: Int
    @State private var player: AVPlayer
    
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        videoURL: URL,
        actionText: LocalizedStringResource,
        action: @escaping () -> Void,
        currentStep: Binding<Int>
    ) {
        self.title = title
        self.description = description
        self.videoURL = videoURL
        self.actionText = actionText
        self.action = action
        self.player = AVPlayer(url: videoURL)
        self._currentStep = currentStep
    }
    
    private var isLastStep: Bool {
        currentStep == PassportScanStep.allCases.count - 1
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    var body: some View {
        VStack(spacing: 36) {
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
                Text(title)
                    .h4()
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .body2()
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            HorizontalDivider()
            HStack {
                if isLastStep {
                    AppButton(text: actionText, rightIcon: Icons.arrowRight) {
                        action()
                    }
                } else {
                    StepIndicator(steps: PassportScanStep.allCases.count, currentStep: currentStep)
                    Spacer()
                    AppButton(text: actionText, rightIcon: Icons.arrowRight, width: nil) {
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
    PassportScanTutorialButton()
}
