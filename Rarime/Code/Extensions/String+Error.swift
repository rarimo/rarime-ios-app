import Foundation

extension String: Error {}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
