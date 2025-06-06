import Foundation

struct JsonApiRelationship: Codable {
    let data: JsonApiRelationshipData
}

struct JsonApiRelationshipData: Codable {
    let id: String
    let type: String
}
