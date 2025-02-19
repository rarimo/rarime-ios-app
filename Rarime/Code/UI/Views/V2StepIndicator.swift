import SwiftUI

struct V2StepIndicator: View {
    let steps: Int
    let currentStep: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1000)
                    .fill(index == currentStep ? .baseBlack : .baseBlack.opacity(0.1))
                    .frame(width: 6, height: index == currentStep ? 16 : 6)
                    .animation(.easeInOut(duration: 0.4), value: index == currentStep)
            }
        }
    }
}

#Preview() {
    V2StepIndicator(steps: 4, currentStep: 1)
}
