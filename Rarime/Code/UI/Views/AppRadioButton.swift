import SwiftUI

struct AppRadioButton<Label: View>: View {
    let isSelected: Bool
    let onSelect: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: onSelect) {
            HStack {
                label()
                Spacer()
                Circle()
                    .stroke(.componentHovered, lineWidth: 2)
                    .frame(width: 16)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? .primaryDark : .clear, lineWidth: 5)
                            .frame(width: 13)
                    )
            }
            .padding(16)
            .background(.backgroundOpacity, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    VStack {
        AppRadioButton(isSelected: true, onSelect: {}) {
            Text(String("Selected"))
        }
        AppRadioButton(isSelected: false, onSelect: {}) {
            Text(String("Not Selected"))
        }
    }
    .padding()
    .background(.backgroundPrimary)
}
