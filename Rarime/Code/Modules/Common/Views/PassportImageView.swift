import SwiftUI

struct PassportImageView: View {
    var image: UIImage?
    var bgColor: Color = .backgroundPrimary

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .background(.white)
                .clipShape(Circle())
        } else {
            Image(Icons.user)
                .iconLarge()
                .padding(12)
                .background(bgColor)
                .clipShape(Circle())
        }
    }
}

#Preview {
    VStack {
        PassportImageView(image: UIImage(named: "IntroApp"))
        PassportImageView(image: nil, bgColor: .primaryMain)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.backgroundPrimary)
}
