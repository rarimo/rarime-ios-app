import SwiftUI

struct BiometryRecoveryFaceView: View {
    @EnvironmentObject private var viewModel: BiometryRecoveryView.ViewModel

    @State private var isScanning = false

    @State private var loadingCircleSize: CGFloat?

    @State private var loadingCircleCornerRadius: CGFloat = 150

    var body: some View {
        VStack {
            Spacer()
            Text("Scan your face")
                .h4()
                .padding(.bottom, 50)
                .padding(.horizontal)
            faceCircle
            Text("Look straight into the screen with good lighting conditions")
                .body2()
                .multilineTextAlignment(.center)
                .foregroundStyle(.textSecondary)
                .padding(.top, 40)
                .padding(.horizontal)
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
                    RoundedRectangle(cornerRadius: loadingCircleCornerRadius)
                        .strokeBorder(.primaryMain, lineWidth: loadingCircleSize)
                    if loadingCircleSize == 150 {
                        BiometryRecoverySuccessView()
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
            }
        }
        .frame(width: 300, height: 300)
    }
}

#Preview {
    BiometryRecoveryFaceView()
        .environmentObject(BiometryRecoveryView.ViewModel())
}
