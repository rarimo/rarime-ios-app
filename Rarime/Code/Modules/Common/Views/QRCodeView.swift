import QRCode
import SwiftUI

struct QRCodeView: View {
    let code: String
    let size: CGFloat = 160

    var qrImage: UIImage? {
        let doc = QRCode.Document(utf8String: code)
        doc.logoTemplate = QRCode.LogoTemplate(
            image: UIImage(named: Icons.rarime)!.cgImage!,
            path: CGPath(rect: CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.3), transform: nil),
            inset: 3
        )

        let cgImage = doc.cgImage(CGSize(width: 400, height: 400))
        return cgImage == nil ? nil : UIImage(cgImage: cgImage!)
    }

    var body: some View {
        ZStack {
            ZStack {
                if let qrImage {
                    Image(uiImage: qrImage).square(size)
                } else {
                    Image(Icons.qrCode)
                        .square(size)
                        .foregroundColor(.errorMain)
                }
            }
            .padding(14)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.textPrimary, lineWidth: 7)
            )
        }
        .padding(4)
    }
}

#Preview {
    QRCodeView(code: "https://youtu.be/dQw4w9WgXcQ")
}
