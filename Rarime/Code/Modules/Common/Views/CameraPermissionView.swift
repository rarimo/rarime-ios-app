import AVFoundation
import SwiftUI

struct CameraPermissionView<Content: View>: View {
    let delay: TimeInterval
    let onCancel: () -> Void
    let content: () -> Content

    @State private var isChecking = true
    @State private var isGranted = false

    init(
        delay: TimeInterval = 0.0,
        onCancel: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.delay = delay
        self.onCancel = onCancel
        self.content = content
    }

    private func checkPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                isGranted = granted
                isChecking = false
            }
        }
    }

    var body: some View {
        ZStack {
            if isGranted {
                content()
            } else {
                Color.black.ignoresSafeArea()
            }
        }
        .alert(
            "Camera Permission",
            isPresented: .constant(!isChecking && !isGranted),
            actions: {
                Button("Cancel") { onCancel() }
                Button("Open Settings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    onCancel()
                }
            },
            message: {
                Text("Please allow camera access in settings to continue")
            }
        )
        .onAppear(perform: checkPermission)
    }
}
