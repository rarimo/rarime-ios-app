import SwiftUI

private enum FieldType {
    case documentId, date
}

struct MrzFormView: View {
    let onSubmitted: (String) -> Void

    @State private var documentId = ""
    @State private var documentIdError = ""

    @State private var dateOfBirth = ""
    @State private var dateOfBirthError = ""

    @State private var dateOfExpiry = ""
    @State private var dateOfExpiryError = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Please fill these fields")
                .subtitle4()
                .foregroundStyle(.textSecondary)
            VStack(spacing: 16) {
                AppTextField(
                    text: $documentId,
                    errorMessage: $documentIdError,
                    placeholder: String(localized: "Document ID (AB123456)")
                )
                .autocapitalization(.allCharacters)
                .textContentType(.oneTimeCode)
                .autocorrectionDisabled(true)
                AppTextField(
                    text: $dateOfBirth,
                    errorMessage: $dateOfBirthError,
                    placeholder: String(localized: "Date of birth (dd/mm/yy)")
                )
                AppTextField(
                    text: $dateOfExpiry,
                    errorMessage: $dateOfExpiryError,
                    placeholder: String(localized: "Date of expiry (dd/mm/yy)")
                )
            }
            AppButton(
                text: "Enter",
                action: submit
            )
            .controlSize(.large)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func submit() {
        if validateForm() {
            let birthDate = DateUtil.mrzDateFormatter.date(from: dateOfBirth)!
            let expiryDate = DateUtil.mrzDateFormatter.date(from: dateOfExpiry)!
            let mrzKey = PassportUtils.getMRZKey(
                passportNumber: documentId,
                dateOfBirth: DateUtil.passportDateFormatter.string(from: birthDate),
                dateOfExpiry: DateUtil.passportDateFormatter.string(from: expiryDate)
            )
            onSubmitted(mrzKey)
        }
    }

    private func validateForm() -> Bool {
        validateField(field: documentId, error: $documentIdError, type: .documentId)
        validateField(field: dateOfBirth, error: $dateOfBirthError, type: .date)
        validateField(field: dateOfExpiry, error: $dateOfExpiryError, type: .date)

        return documentIdError.isEmpty && dateOfBirthError.isEmpty && dateOfExpiryError.isEmpty
    }

    private func validateField(
        field: String,
        error: Binding<String>,
        type: FieldType
    ) {
        if field.isEmpty {
            error.wrappedValue = "This field is required"
            return
        }

        error.wrappedValue = switch type {
        case .documentId: validateDocumentId(documentId: field) ? "" : "Invalid document ID"
        case .date: validateDate(dateString: field) ? "" : "Invalid date"
        }
    }

    private func validateDocumentId(documentId: String) -> Bool {
        let documentIdPattern = "^[A-Z0-9]+$"
        let documentIdPredicate = NSPredicate(format: "SELF MATCHES %@", documentIdPattern)
        return documentIdPredicate.evaluate(with: documentId)
    }

    private func validateDate(dateString: String) -> Bool {
        let date = DateUtil.mrzDateFormatter.date(from: dateString)
        return date != nil
    }
}

#Preview {
    MrzFormView(onSubmitted: { _ in })
}
