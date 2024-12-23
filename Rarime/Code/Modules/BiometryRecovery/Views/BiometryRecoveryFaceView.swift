import SwiftUI

struct BiometryRecoveryFaceView: View {
    @EnvironmentObject private var viewModel: BiometryRecoveryView.ViewModel

    @State private var isScanning = false

    @State private var isScanned = false

    @State private var loadingCircleSize: CGFloat?

    @State private var loadingCircleCornerRadius: CGFloat = 150

    @State private var restoringTextDots: String = ""

    @State private var recoveryTask: Task<Void, Never>? = nil

    let onRecovered: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text(isScanned ? "Restoring access\n" + restoringTextDots : "Scan your face")
                .h4()
                .multilineTextAlignment(.center)
                .padding(.bottom, isScanned ? 10 : 50)
                .padding(.horizontal)
            faceCircle
            Text("Look straight into the screen with good lighting conditions")
                .body2()
                .multilineTextAlignment(.center)
                .foregroundStyle(.textSecondary)
                .padding(.top, 40)
                .padding(.horizontal)
                .opacity(isScanned ? 0 : 1)
            Spacer()
            AppButton(
                text: "Continue",
                rightIcon: Icons.arrowRight,
                action: {
                    isScanning = true

                    viewModel.startScanning()
                }
            )
            .padding(.horizontal)
            .opacity(isScanning ? 0 : 1)
            .disabled(isScanning)
        }
        .onDisappear {
            recoveryTask = nil

            viewModel.stopScanning()
        }
    }

    var faceCircle: some View {
        ZStack {
            Circle()
                .strokeBorder(.primaryDark, lineWidth: 5)
                .background(Circle().foregroundStyle(.primaryMain))
                .opacity(0.25)
            if let image = viewModel.currentFrame {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .clipped()
                    .scaleEffect(x: -1, y: 1)
                    .frame(maxWidth: 290, maxHeight: 290)
                if let loadingCircleSize {
                    if loadingCircleSize == 150 {
                        RoundedRectangle(cornerRadius: loadingCircleCornerRadius)
                            .foregroundStyle(.primaryMain)
                        BiometryRecoverySuccessView()
                        if isScanned {
                            recoveryProcess
                        }
                    } else {
                        Circle()
                            .strokeBorder(.primaryMain, lineWidth: loadingCircleSize)
                    }

                } else {
                    Circle()
                        .trim(from: 0.0, to: viewModel.loadingProgress)
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(.primaryMain)
                        .rotationEffect(.degrees(-90))
                }
            } else {
                Image(Icons.userFocus)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.primaryDark)
                    .frame(width: 75, height: 75)
            }
        }
        .onChange(of: viewModel.faceImage) { image in
            if image == nil {
                return
            }

            viewModel.stopScanning()

            Task { @MainActor in
                for newLoadingCircleSize in 6 ... 150 {
                    loadingCircleSize = CGFloat(newLoadingCircleSize)

                    try await Task.sleep(nanoseconds: 10_000_000)
                }

                for newCornerRadius in (25 ... 149).reversed() {
                    loadingCircleCornerRadius = CGFloat(newCornerRadius)

                    try await Task.sleep(nanoseconds: 20_000_000)
                }

                withAnimation {
                    isScanned = true
                }

                runRecoveryProcess()

                while true {
                    try await Task.sleep(nanoseconds: 100_000_000)

                    if restoringTextDots.count == 30 {
                        restoringTextDots = ""
                    } else {
                        restoringTextDots += "."
                    }
                }
            }
        }
        .frame(width: 300, height: 300)
    }

    var recoveryProcess: some View {
        VStack(spacing: 35) {
            ForEach(BiometryRecoveryProgress.allCases, id: \.rawValue) { progress in
                VStack {
                    Text(progress.description)
                        .body2()
                        .align()
                        .foregroundStyle(.baseBlack)
                    RecoveryProcessLoader(biometryRecoveryProgress: progress)
                }
                .padding(.horizontal)
            }
        }
        .transition(.opacity)
    }

    func runRecoveryProcess() {
        recoveryTask = Task { @MainActor in
            do {
                guard let image = viewModel.faceImage else {
                    return
                }

                var isRecovered = false
                viewModel.recoverByBiometry(image) {
                    isRecovered = true
                }

                for progress in BiometryRecoveryProgress.allCases {
                    viewModel.markRecoveryProgress(progress)

                    try await Task.sleep(nanoseconds: UInt64(progress.progressTime) * NSEC_PER_SEC)
                }

                while !isRecovered {
                    try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                }

                try UserManager.shared.user?.save()

                onRecovered()
            } catch {
                LoggerUtil.common.error("Error recovering by biometry: \(error)")
            }
        }
    }
}

struct RecoveryProcessLoader: View {
    @EnvironmentObject var viewModel: BiometryRecoveryView.ViewModel

    var biometryRecoveryProgress: BiometryRecoveryProgress

    @State private var progress: Double = 0

    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.baseBlack)
            if biometryRecoveryProgress.rawValue <= viewModel.recoveryProgress?.rawValue ?? -1 {
                VStack {}
                    .onAppear {
                        Task { @MainActor in
                            while progress < 1 {
                                progress += 0.01

                                try await Task.sleep(nanoseconds: UInt64(biometryRecoveryProgress.progressTime) * NSEC_PER_SEC / 100)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    BiometryRecoveryFaceView {}
        .environmentObject(BiometryRecoveryView.ViewModel())
}
