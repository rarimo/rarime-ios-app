import SwiftUI

struct PrizeScanFinishedView: View {
    let onViewWallet: () -> Void

    private var imageToShare: Data {
        // TODO: use different image for sharing
        UIImage(named: "HiddenPrizeBg")!.pngData()!
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Image(.checkLine)
                    .square(24)
                    .padding(12)
                    .background(.baseWhite.opacity(0.2), in: Circle())
                    .foregroundStyle(.baseWhite)
                    .overlay(Circle().stroke(.baseWhite, lineWidth: 3))
                Text("Finished")
                    .h3()
                    .foregroundStyle(.baseWhite)
                    .padding(.top, 32)
                Text("The prize has been successfully credited to your wallet.")
                    .body3()
                    .foregroundStyle(.baseWhite.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 260)
                    .padding(.top, 12)
                Spacer()
                VStack(spacing: 12) {
                    Button(action: onViewWallet) {
                        Text("View Wallet")
                            .foregroundStyle(.baseWhite)
                            .buttonLarge()
                            .frame(maxWidth: .infinity)
                            .padding(18)
                            .background(.baseWhite.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                    }
                    ShareLink(
                        item: imageToShare,
                        subject: Text("Hidden Prize Winner"),
                        preview: SharePreview("Hidden Prize Winner", image: Image(uiImage: UIImage(data: imageToShare)!))
                    ) {
                        Text("Share")
                            .buttonLarge()
                            .foregroundStyle(.baseBlack)
                            .frame(maxWidth: .infinity, maxHeight: 56)
                            .background(.baseWhite, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    PrizeScanFinishedView(onViewWallet: {})
        .background(.baseBlack)
}
