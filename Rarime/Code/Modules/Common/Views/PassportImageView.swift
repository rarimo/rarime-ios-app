import SwiftUI

struct PassportImageView: View {
    var image: UIImage?
    var size: CGFloat = 56
    var bgColor: Color = .backgroundPrimary

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(.componentPrimary, lineWidth: 1))
        } else {
            Image(Icons.user)
                .square(size * 0.5)
                .padding(size * 0.25)
                .background(bgColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(.componentPrimary, lineWidth: 1))
        }
    }
}

#Preview {
    VStack {
        PassportImageView(image: UIImage(named: Images.passportNfc))
        PassportImageView(image: nil, bgColor: .primaryMain)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.backgroundPrimary)
}
