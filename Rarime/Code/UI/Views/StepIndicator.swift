import SwiftUI

struct StepIndicator: View {
    let steps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index == currentStep ? .primaryMain : .bgComponentPrimary)
                    .frame(width: index == currentStep ? 16 : 6, height: 6)
            }
        }
    }
}

#Preview {
    StepIndicator(steps: 8, currentStep: 2)
}
