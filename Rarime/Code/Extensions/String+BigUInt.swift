import Foundation
import BigInt

extension String {
    func toBigUInt(toUTF8: Bool = false) -> String {
        if toUTF8 {
            guard let utf8Data = self.data(using: .utf8) else {
                return "0"
            }
            return "\(BigUInt(utf8Data))"
        }
        
        if self.lowercased().hasPrefix("0x") {
            let hexString = String(self.dropFirst(2))
            if let hexValue = BigUInt(hexString, radix: 16) {
                return "\(hexValue)"
            } else {
                return "0"
            }
        }
        
        if let decimalValue = Decimal(string: self) {
            return "\(decimalValue)"
        }
        
        return "0"
    }
}
