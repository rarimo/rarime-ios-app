import SwiftUI

struct V2StepIndicator: View {
    let steps: Int
    let currentStep: Int
    let orientation: Axis
    
    init(steps: Int, currentStep: Int, orientation: Axis = .horizontal) {
        self.steps = steps
        self.currentStep = currentStep
        self.orientation = orientation
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1000)
                    .fill(index == currentStep ? .baseBlack : .baseBlack.opacity(0.1))
                    .frame(width: index == currentStep ? 16 : 6, height: 6)
            }
        }
        .rotationEffect(orientation == .horizontal ? Angle(degrees: 0) : Angle(degrees: 90))
    }
}

#Preview {
    VStack(spacing: 100) {
        V2StepIndicator(steps: 4, currentStep: 1)
        V2StepIndicator(steps: 4, currentStep: 1, orientation: .vertical)
    }
}
