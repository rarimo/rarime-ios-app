import SwiftUI

struct ScanPassportLayoutView<Content: View>: View {
    let currentStep: Int
    let title: LocalizedStringResource
    let onPrevious: (() -> Void)?
    let onClose: () -> Void
    
    var steps: Int = 2
    
    @ViewBuilder let content: Content
    
    init(
        currentStep: Int,
        title: LocalizedStringResource,
        onPrevious: (() -> Void)? = nil,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.currentStep = currentStep
        self.title = title
        self.onPrevious = onPrevious
        self.onClose = onClose
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 38) {
                ZStack(alignment: .center) {
                    StepIndicator(steps: steps, currentStep: currentStep)
                    
                    HStack(alignment: .center) {
                        if let onPrevious {
                            AppIconButton(icon: Icons.arrowLeftSLine, action: onPrevious)
                        }
                        Spacer()
                        AppIconButton(icon: Icons.closeFill, action: onClose)
                    }
                }
                Text(title)
                    .h2()
                    .foregroundStyle(.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 20)
    }
}

#Preview {
    ScanPassportLayoutView(
        currentStep: 0,
        title: LocalizedStringResource("Scan your Passport", table: "preview"),
        onClose: {}
    ) {
        Rectangle()
            .fill(.black)
            .frame(height: 300)
        Spacer()
    }
}
