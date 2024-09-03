import SwiftUI

enum AppAlertType {
    case success
    case error
    case processing
}

struct AppAlert: View {
    let type: AppAlertType
    let message: String?

    private var bgColor: Color {
        switch type {
        case .success: .successMain
        case .error: .errorMain
        case .processing: .warningMain
        }
    }

    private var icon: String {
        switch type {
        case .success: Icons.info
        case .error: Icons.warning
        case .processing: Icons.info
        }
    }

    private var title: String {
        switch type {
        case .success: String(localized: "Success")
        case .error: String(localized: "Error")
        case .processing: String(localized: "Processing")
        }
    }

    private var defaultMessage: String {
        switch type {
        case .success: String(localized: "Operation completed successfully")
        case .error: String(localized: "An error has occured, please try again")
        case .processing: String(localized: "Please wait")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            if type == .processing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.baseWhite)
            } else {
                Image(icon).iconMedium()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .subtitle4()
                Text(message ?? defaultMessage)
                    .body4()
                    .opacity(0.64)
            }
            Spacer()
        }
        .padding(16)
        .background(bgColor, in: RoundedRectangle(cornerRadius: 24))
        .foregroundStyle(.baseWhite)
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack {
        AppAlert(type: .success, message: "Success message")
        AppAlert(type: .error, message: "Error message")
        AppAlert(type: .processing, message: "Processing message")
    }
}
