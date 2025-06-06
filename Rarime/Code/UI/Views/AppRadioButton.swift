import SwiftUI

struct AppRadioButton<Label: View>: View {
    let isSelected: Bool
    let onSelect: () -> Void
    let label: (() -> Label)?

    init(isSelected: Bool, onSelect: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.label = label
    }

    init(isSelected: Bool, onSelect: @escaping () -> Void) where Label == EmptyView {
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.label = nil
    }

    var body: some View {
        Button(action: onSelect) {
            if let label {
                HStack {
                    label()
                    Spacer()
                    radioCircle
                }
                .padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.bgComponentPrimary, lineWidth: 1)
                )
            } else {
                radioCircle
            }
        }
    }

    private var radioCircle: some View {
        Circle()
            .stroke(isSelected ? .textPrimary : .textPlaceholder, lineWidth: 1.5)
            .frame(width: 18)
            .overlay(
                Circle()
                    .fill(isSelected ? .textPrimary : .clear)
                    .frame(width: 10)
            )
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
    .background(.bgPrimary)
}
