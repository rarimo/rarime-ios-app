import Foundation

protocol JSONCodable: Codable {}

extension JSONCodable {
    var json: Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}
