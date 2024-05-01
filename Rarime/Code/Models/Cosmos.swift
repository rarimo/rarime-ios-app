import Alamofire
import Foundation

class Cosmos {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func getSpendableBalances(_ address: String) async throws -> CosmosSpendableBalancesResponse {
        var requestURL = url
        requestURL.append(path: "/cosmos/bank/v1beta1/spendable_balances/\(address)")
        
        return try await AF.request(requestURL)
            .serializingDecodable(CosmosSpendableBalancesResponse.self)
            .result
            .get()
    }
}


struct CosmosSpendableBalancesResponse: Codable {
    let balances: [CosmosSpendableBalance]
}

struct CosmosSpendableBalance: Codable {
    let denom, amount: String
}
