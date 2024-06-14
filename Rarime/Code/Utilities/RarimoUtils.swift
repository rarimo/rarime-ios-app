import Foundation

class RarimoUtils {
    static func isValidAddress(_ address: String) -> Bool {
        let pattern = "^rarimo[0-9a-z]{39}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex?.firstMatch(in: address, options: [], range: range) != nil
    }
    
    static func formatAddress(_ address: String) -> String {
       guard address.count > 20 else { return address }
       return "\(address.prefix(12))...\(address.suffix(8))"
   }
    
    static func formatBalance(_ balance: Double) -> String {
        return (balance / Double(Rarimo.rarimoTokenMantis)).formatted()
    }
}
