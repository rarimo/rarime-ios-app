import SwiftUI

struct ShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )

        controller.excludedActivityTypes = [
            .assignToContact,
            .print
        ]

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            ShareActivityView(activityItems: ["Hello, World!"])
        }
}
