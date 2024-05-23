import Foundation
import SwiftUI

extension Image {
    func square(_ size: CGFloat) -> some View {
        self
            .resizable()
            .frame(width: size, height: size)
    }

    func iconLarge() -> some View {
        self.square(32)
    }

    func iconMedium() -> some View {
        self.square(20)
    }

    func iconSmall() -> some View {
        self.square(16)
    }
}
