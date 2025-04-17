import Foundation

extension Data {
    var utf8: String {
        String(data: self, encoding: .utf8) ?? ""
    }
    
    var ascii: String {
        String(data: self, encoding: .ascii) ?? ""
    }
}
