import Foundation

protocol QuickCodable: Codable {}

extension QuickCodable {
    var json: Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}
