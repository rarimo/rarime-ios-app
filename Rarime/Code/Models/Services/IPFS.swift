import Alamofire
import Foundation
import UIKit

class IPFS {
    let url: URL
    
    init(_ url: URL = ConfigManager.shared.freedomTool.ipfsNodeURL) {
        self.url = url
    }
    
    func load<T: Decodable>(_ cid: String) async throws -> T {
        let url = url
            .appendingPathComponent("ipfs")
            .appendingPathComponent(cid)
        
        return try await AF.request(url)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(T.self)
            .result
            .get()
    }
    
    func loadImage(_ cid: String) async throws -> UIImage {
        let imageUrl = url
            .appendingPathComponent("ipfs")
            .appendingPathComponent(cid)
        
        let data = try await AF.request(imageUrl)
            .validate()
            .serializingData()
            .result
            .get()
        
        guard let image = UIImage(data: data) else {
            throw "invalid image data"
        }
        
        return image
    }
}
