import SwiftUI

struct AppCheckbox: View {
    @Binding var checked: Bool
    var onToggle: ((Bool) -> Void)?
    
    @ViewBuilder var background: some View {
        if checked {
            Gradients.gradientSixth
        } else {
            Color.bgComponentPrimary
        }
    }

    var body: some View {
        ZStack {
            Image(Icons.checkLine)
                .iconSmall()
                .foregroundStyle(.invertedLight)
                .opacity(checked ? 1 : 0)
        }
        .frame(width: 20, height: 20)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(.bgComponentPrimary, lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: checked)
        .onTapGesture {
            checked.toggle()
            onToggle?(checked)
            FeedbackGenerator.shared.impact(.light)
        }
    }
}

private struct PreviewView: View {
    @State private var checked = false

    var body: some View {
        AppCheckbox(checked: $checked)
    }
}

#Preview {
    PreviewView()
}
