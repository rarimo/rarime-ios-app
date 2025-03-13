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
                .padding(16)
                .background(.bgComponentPrimary, in: RoundedRectangle(cornerRadius: 12))
            } else {
                radioCircle
            }
        }
    }
    
    private var radioCircle: some View {
        Circle()
            .stroke(isSelected ? .secondaryMain : .bgComponentHovered, lineWidth: 1)
            .frame(width: 20)
            .overlay(
                Circle()
                    .fill(isSelected ? .secondaryMain : .clear)
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
