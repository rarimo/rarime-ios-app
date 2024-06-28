import SwiftUI

struct AppCheckbox: View {
    @Binding var checked: Bool
    var onToggle: ((Bool) -> Void)?

    var body: some View {
        ZStack {
            Image(Icons.check)
                .iconSmall()
                .foregroundStyle(.baseBlack)
                .opacity(checked ? 1 : 0)
        }
        .frame(width: 20, height: 20)
        .background(checked ? .primaryMain : .componentPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(.componentPrimary, lineWidth: 1))
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
