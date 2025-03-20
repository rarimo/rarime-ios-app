struct NoirRegisterIdentityInputs: Codable {
    let dg1, dg15, ec: [String]
    let icaoRoot: String
    let inclusionBrances, pk, reductionPk, sa: [String]
    let sig: [String]
    let skIdentity: String

    enum CodingKeys: String, CodingKey {
        case dg1, dg15, ec
        case icaoRoot = "icao_root"
        case inclusionBrances = "inclusion_brances"
        case pk
        case reductionPk = "reduction_pk"
        case sa, sig
        case skIdentity = "sk_identity"
    }

    func toAnyMap() -> [String: Any] {
        var result: [String: Any] = [:]
        result["dg1"] = dg1
        result["dg15"] = dg15
        result["ec"] = ec
        result["icao_root"] = icaoRoot
        result["inclusion_brances"] = inclusionBrances
        result["pk"] = pk
        result["reduction_pk"] = reductionPk
        result["sa"] = sa
        result["sig"] = sig
        result["sk_identity"] = skIdentity

        return result
    }
}
