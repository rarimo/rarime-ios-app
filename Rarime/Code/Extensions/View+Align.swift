import SwiftUI

extension View {
    func align(_ aligment: Alignment = .leading) -> some View {
        self.frame(maxWidth: .infinity, alignment: aligment)
    }
}
