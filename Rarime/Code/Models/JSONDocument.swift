import SwiftUI
import UniformTypeIdentifiers

class JSONDocument: FileDocument {
    let json: Data

    static var readableContentTypes: [UTType] = [.json]

    init(_ json: Data) {
        self.json = json
    }

    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.json = data
            return
        }

        self.json = Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: json)
    }
}
