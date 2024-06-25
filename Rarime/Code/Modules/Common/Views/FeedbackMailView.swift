import MessageUI
import SwiftUI

struct FeedbackMailView: View {
    @Binding var isShowing: Bool
    @State private var feedbackAttachment = Data()

    var body: some View {
        if !feedbackAttachment.isEmpty {
            MailView(
                subject: "Feedback from: \(UIDevice.modelName)",
                attachment: feedbackAttachment,
                fileName: "logs.txt",
                isShowing: $isShowing,
                result: .constant(nil)
            )
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .controlSize(.large)
                .onAppear(perform: fetchLogsForFeedback)
        }
    }

    func fetchLogsForFeedback() {
        Task { @MainActor in
            LoggerUtil.common.info("Exporting logs")

            let logEntries = (try? LoggerUtil.export()) ?? []
            let logData = logEntries.map { $0.description }.joined(separator: "\n")

            self.feedbackAttachment = logData.data(using: .utf8) ?? Data()
        }
    }
}

#Preview {
    FeedbackMailView(isShowing: .constant(true))
}
