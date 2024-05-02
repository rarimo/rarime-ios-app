import Foundation

class RarimoUtils {
    static func isValidAddress(_ address: String) -> Bool {
        let pattern = "^rarimo[0-9a-z]{39}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex?.firstMatch(in: address, options: [], range: range) != nil
    }
}
