import UIKit
import SwiftUI
import MessageUI

struct ShareFeedbackMailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(
            isShowing: Binding<Bool>,
            result: Binding<Result<MFMailComposeResult, Error>?>
        ) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            defer {
                isShowing = false
            }
            
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            isShowing: $isShowing,
            result: $result
        )
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareFeedbackMailView>
    ) -> MFMailComposeViewController {
        let recipient = ConfigManager.shared.feedback.feedbackEmail
        let subject = "Feedback from: \(UIDevice.modelName)"
        
        LoggerUtil.common.info("Exporting logs")
        
        let logEntries = (try? LoggerUtil.export()) ?? []
        let logData = logEntries.map { $0.description }.joined(separator: "\n")
        
        let attachment = logData.data(using: .utf8) ?? Data()
        let mimeType = "text/plain"
        let fileName = "logs.txt"
        
        let vc = MFMailComposeViewController()
        
        vc.setSubject(subject)
        vc.setToRecipients([recipient])
        vc.addAttachmentData(attachment, mimeType: mimeType, fileName: fileName)
        
        vc.mailComposeDelegate = context.coordinator
        
        return vc
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<ShareFeedbackMailView>
    ) {}
}
