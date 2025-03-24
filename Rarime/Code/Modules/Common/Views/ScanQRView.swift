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
                        LoggerUtil.common.error("Failed to scan QR code: \(error, privacy: .public)")
                        onScan("")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            ZStack {
                Color.baseBlack
                    .opacity(0.6)
                    .mask(MaskShape(size: 247).fill(style: FillStyle(eoFill: true)))
                Image(Images.qrFrame).square(247)
                Text("Position the QR code in the middle of the scanner")
                    .body3()
                    .foregroundStyle(.baseWhite)
                    .multilineTextAlignment(.center)
                    .frame(width: 220)
                    .padding(.top, 360)
            }
            .ignoresSafeArea()
            Button(action: onBack) {
                Image(Icons.closeFill)
                    .iconMedium()
                    .foregroundStyle(.baseWhite)
            }
            .padding(.all, 10)
            .backgroundBlur(bgColor: .bgComponentBasePrimary)
            .clipShape(Circle())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding([.top, .trailing], 20)
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
