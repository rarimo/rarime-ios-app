struct NoirRegisterIdentityInputs: Codable {
    let dg1, dg15, ec: [String]
    let icaoRoot: String
    let inclusionBranches, pk, reductionPk, sa: [String]
    let sig: [String]
    let skIdentity: String

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
