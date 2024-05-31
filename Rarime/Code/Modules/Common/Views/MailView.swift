import UIKit
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let subject: String
    let attachment: Data
    let fileName: String
    
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
        context: UIViewControllerRepresentableContext<MailView>
    ) -> MFMailComposeViewController {
        let recipient = ConfigManager.shared.feedback.feedbackEmail
        
        let vc = MFMailComposeViewController()
        
        vc.setSubject(subject)
        vc.setToRecipients([recipient])
        vc.addAttachmentData(attachment, mimeType: "text/plain", fileName: fileName)
        
        vc.mailComposeDelegate = context.coordinator
        
        return vc
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>
    ) {}
}
