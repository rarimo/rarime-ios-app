import SwiftUI

func ErrorAlert(
    _ error: Errors,
    _ dismissButton: Alert.Button = .default(Text("Ok"))
) -> Alert {
    Alert(
        title: Text("Error"),
        message: Text(error.localizedDescription ?? "Unknown"),
        dismissButton: dismissButton
    )
}

#Preview {
    let alert = ErrorAlert(.unknown)
    
    return VStack {}
        .alert(isPresented: .constant(true), content: { alert })
    
}
