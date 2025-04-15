#if DEVELOPMENT

import SwiftUI

struct DebugOptionsView: View {
    var body: some View {
        VStack {
            Text("Debug options")
                .h3()
            Spacer()
            VStack(spacing: 20) {
                Toggle(
                    "Force registration",
                    isOn: .init(
                        get: { DebugController.shared.shouldForceRegistration },
                        set: { value in DebugController.shared.shouldForceRegistration = value }
                    )
                )
                .bold()
                Toggle(
                    "Force light registration",
                    isOn: .init(
                        get: { DebugController.shared.shouldForceRegistration },
                        set: { value in DebugController.shared.shouldForceLightRegistration = value }
                    )
                )
                .bold()
            }
        }
        .padding()
        .presentationDetents([.fraction(0.22)])
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: DebugOptionsView.init)
}

#endif
