import Foundation

extension Data {
    var utf8: String {
        String(data: self, encoding: .utf8) ?? ""
    }
}

extension Data {
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
