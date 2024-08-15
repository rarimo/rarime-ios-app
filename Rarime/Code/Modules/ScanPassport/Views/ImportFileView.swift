import SwiftUI

struct ImportFileView: View {
    @State private var isFileImporting = false
    
    let onFinish: (Passport) -> Void
    
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isFileImporting = true
            }
        }
        .fileImporter(isPresented: $isFileImporting, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                do {
                    if !url.startAccessingSecurityScopedResource() {
                        throw "Failed to access file"
                    }
                        
                    let passport = try JSONDecoder().decode(Passport.self, from: Data(contentsOf: url))
                        
                    url.stopAccessingSecurityScopedResource()
                        
                    onFinish(passport)
                } catch {
                    LoggerUtil.common.error("Failed to get passport from file: \(error, privacy: .public)")
                        
                    onClose()
                }
            case .failure(let error):
                LoggerUtil.common.error("Failed to import file: \(error, privacy: .public)")
                    
                isFileImporting.toggle()
                    
                onClose()
            }
        }
    }
}

#Preview {
    ImportFileView(onFinish: { _ in }, onClose: {})
}
