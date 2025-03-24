import SwiftUI

struct V2VerticalStepIndicator: View {
    let steps: Int
    let currentStep: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1000)
                    .fill(index == currentStep ? .textPrimary : .primaryLight)
                    .frame(width: 6, height: index == currentStep ? 16 : 6)
                    .animation(
                        .interpolatingSpring(mass: 1, stiffness: 100, damping: 15),
                        value: index == currentStep
                    )
            }
        }
    }
}

struct V2HorizontalStepIndicator: View {
    let steps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1000)
                    .fill(index == currentStep ? .textPrimary : .primaryLight)
                    .frame(width: index == currentStep ? 16 : 6, height: 6)
                    .animation(
                        .interpolatingSpring(mass: 1, stiffness: 100, damping: 15),
                        value: index == currentStep
                    )
            }
        }
    }
}

#Preview() {
    VStack(spacing: 24) {
        V2VerticalStepIndicator(steps: 4, currentStep: 1)
        V2HorizontalStepIndicator(steps: 8, currentStep: 3)
    }
}
