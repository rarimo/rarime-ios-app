//

import SwiftUI

struct PreDownloadView: View {
    @EnvironmentObject private var circuitDataManager: CircuitDataManager
    
    let onFinish: () -> Void
    
    @State private var message: String = "Waiting"
    
    var body: some View {
        VStack {
            Spacer()
            Image(Images.rarimeIcon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.primary)
                .frame(width: 150, height: 150)
            Text("Downloading additional data")
                .h6()
                .padding(.top, 20)
            Spacer()
            Divider()
            Text(message)
                .body3()
        }
        .background(.backgroundPure)
        .onAppear {
            Task {
                do {
                    try await circuitDataManager.downloadCircuitData( onFinish) { msg in
                        message = msg
                    }
                } catch {
                    LoggerUtil.general.error("\(error)")
                }
            }
        }
    }
}

#Preview {
    PreDownloadView() {}
        .environmentObject(CircuitDataManager.shared)
}
