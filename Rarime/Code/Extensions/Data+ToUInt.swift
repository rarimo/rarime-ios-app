import Foundation

extension Data {
    func toUInt() -> UInt {
        return self.withUnsafeBytes { $0.load(as: UInt.self) }
    }
}
