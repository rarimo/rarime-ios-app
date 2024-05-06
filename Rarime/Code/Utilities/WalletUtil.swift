import Foundation

class WalletUtil {
    static func formatAddress(_ address: String) -> String {
        guard address.count > 20 else { return address }
        return "\(address.prefix(12))...\(address.suffix(8))"
    }
}
