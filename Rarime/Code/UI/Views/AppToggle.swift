import SwiftUI

struct AppToggle: View {
    @Environment(\.isEnabled) var isEnabled

    @Binding var isOn: Bool
    var onChanged: ((Bool) -> Void)?

    var body: some View {
        ZStack {
            if isEnabled {
                RoundedRectangle(cornerRadius: 16).fill(isOn ? .primaryDark : .componentPrimary)
            } else {
                RoundedRectangle(cornerRadius: 16).stroke(.componentDisabled, lineWidth: 1)
            }
            Circle()
                .fill(isEnabled ? .baseWhite : .componentDisabled)
                .shadow(color: isOn ? .clear : .baseBlack.opacity(0.12), radius: 1, x: 1, y: 1)
                .padding(2)
                .offset(x: isOn ? 8 : -8)
            Image(Icons.lockFill).square(12)
                .foregroundStyle(.textDisabled)
                .offset(x: isOn ? 8 : -8)
                .opacity(isEnabled ? 0 : 1)
        }
        .frame(width: 40, height: 24)
        .animation(.easeInOut(duration: 0.2), value: isOn)
        .onTapGesture {
            isOn.toggle()
            onChanged?(isOn)
            FeedbackGenerator.shared.impact(.light)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let oldIsOn = isOn
                    isOn = value.translation.width >= 0
                    onChanged?(isOn)
                    if oldIsOn != isOn {
                        FeedbackGenerator.shared.impact(.light)
                    }
                }
        )
    }
}

private struct PreviewView: View {
    @State private var isOn = false

    var body: some View {
        VStack(alignment: .leading) {
            AppToggle(isOn: $isOn)
            AppToggle(isOn: $isOn).disabled(true)
        }
    }
}

#Preview {
    PreviewView()
}
