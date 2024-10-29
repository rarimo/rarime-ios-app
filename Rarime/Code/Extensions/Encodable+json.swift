import Foundation

extension Encodable {
    var json: Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}
