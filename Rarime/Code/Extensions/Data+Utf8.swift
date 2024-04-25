import Foundation

extension Data {
    var utf8: String {
        String(data: self, encoding: .utf8) ?? ""
    }
}
