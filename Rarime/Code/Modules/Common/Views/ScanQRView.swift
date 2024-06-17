import CodeScanner
import SwiftUI

struct ScanQRView: View {
    var onBack: () -> Void
    var onScan: (String) -> Void

    var body: some View {
        ZStack {
            CameraPermissionView(onCancel: onBack) {
                CodeScannerView(codeTypes: [.qr]) { response in
                    switch response {
                    case .success(let result):
                        onScan(result.string)
                    case .failure(let error):
                        LoggerUtil.qr.error("Failed to scan QR code: \(error, privacy: .public)")
                        onScan("")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            ZStack {
                Color.black
                    .opacity(0.7)
                    .mask(MaskShape(size: 235).fill(style: FillStyle(eoFill: true)))
                Image(Images.qrFrame).square(240)
                Text("Place QR code within the frame to scan")
                    .body3()
                    .foregroundStyle(.baseWhite)
                    .multilineTextAlignment(.center)
                    .frame(width: 200)
                    .padding(.top, 320)
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(Icons.caretLeft).iconMedium()
                    }
                    Spacer()
                    Text("Scan QR").subtitle4()
                    Spacer()
                    Rectangle().frame(width: 20, height: 0)
                }
                .foregroundStyle(.baseWhite)
                .padding(20)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MaskShape: Shape {
    let size: Double

    func path(in rect: CGRect) -> Path {
        let cgSize = CGSize(width: size, height: size)

        var path = Rectangle().path(in: rect)
        path.addPath(
            RoundedRectangle(cornerRadius: 10)
                .path(in: CGRect(
                    x: rect.midX - cgSize.width / 2,
                    y: rect.midY - cgSize.height / 2,
                    width: size,
                    height: size
                ))
        )

        return path
    }
}

#Preview {
    ScanQRView(onBack: {}, onScan: { _ in })
}
