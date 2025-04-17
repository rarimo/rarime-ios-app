import Foundation

struct NoirRegisterIdentityInputs: Codable {
    let dg1, dg15, ec: [String]
    let icaoRoot: String
    let inclusionBranches, pk, reductionPk, sa: [String]
    let sig: [String]
    let skIdentity: String

    enum CodingKeys: String, CodingKey {
        case dg1
        case dg15
        case ec
        case icaoRoot = "icao_root"
        case inclusionBranches = "inclusion_branches"
        case pk
        case reductionPk = "reduction_pk"
        case sa
        case sig
        case skIdentity = "sk_identity"
    }

    func toAnyMap() -> [String: Any] {
        var result: [String: Any] = [:]
        result["dg1"] = dg1
        result["dg15"] = dg15
        result["ec"] = ec
        result["icao_root"] = icaoRoot
        result["inclusion_branches"] = inclusionBranches
        result["pk"] = pk
        result["reduction_pk"] = reductionPk
        result["sa"] = sa
        result["sig"] = sig
        result["sk_identity"] = skIdentity

        return result
    }
}
