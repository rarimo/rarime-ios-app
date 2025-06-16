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

    private var icon: ImageResource {
        switch type {
        case .success: .informationLine
        case .error: .warning
        case .processing: .informationLine
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
                    .tint(.baseWhite)
            } else {
                Image(icon)
                    .iconMedium()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .h5()
                Text(message ?? defaultMessage)
                    .body4()
                    .opacity(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(bgColor, in: RoundedRectangle(cornerRadius: 16))
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
