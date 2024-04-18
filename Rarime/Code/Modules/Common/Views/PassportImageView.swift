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
                .overlay(Circle().stroke(.componentPrimary, lineWidth: 1))
        } else {
            Image(Icons.user)
                .iconLarge()
                .padding(12)
                .background(bgColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(.componentPrimary, lineWidth: 1))
        }
    }
}

#Preview {
    VStack {
        PassportImageView(image: UIImage(named: Images.introApp))
        PassportImageView(image: nil, bgColor: .primaryMain)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.backgroundPrimary)
}
