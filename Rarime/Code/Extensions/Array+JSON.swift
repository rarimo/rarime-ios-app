import Foundation

extension Array where Element == String {
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
