import Foundation
import OpenSSL

class CryptoUtils {
    static func getDataFromOpaquePointer(_ pointer: OpaquePointer?) -> Data {
        let bits = BN_num_bits(pointer)
        
        var data = [UInt8](repeating: 0, count: Int((bits + 7) / 8))
        _ = BN_bn2bin(pointer, &data)
        return Data(data)
    }
    
    static func getDataFromPublicKey(_ publicKey: OpaquePointer?) -> Data? {
        switch EVP_PKEY_id(publicKey) {
        case EVP_PKEY_RSA:
            return getModulusFromRSAPublicKey(publicKey)
        case EVP_PKEY_EC:
            return getXYFromECDSAPublicKey(publicKey)
        default:
            return nil
        }
    }
    
    static func getModulusFromRSAPublicKey(_ publicKey: OpaquePointer?) -> Data? {
        let rsaPublicKey = EVP_PKEY_get0_RSA(publicKey)
        guard let rsaPublicKey else { return nil }
        
        let modulus = RSA_get0_n(rsaPublicKey)
        if modulus == nil { return nil }
        
        return getDataFromOpaquePointer(modulus)
    }
    
    static func getExponentFromRSAPublicKey(_ publicKey: OpaquePointer?) -> Data? {
        let rsaPublicKey = EVP_PKEY_get0_RSA(publicKey)
        guard let rsaPublicKey else { return nil }
        
        let exponent = RSA_get0_e(rsaPublicKey)
        if exponent == nil { return nil }
        
        return getDataFromOpaquePointer(exponent)
    }
        
    static func getPublicKeySize(_ publicKey: OpaquePointer?) -> Int {
        Int(EVP_PKEY_bits(publicKey))
    }
    
    static func getXYFromECDSAPublicKey(_ publicKey: OpaquePointer?) -> Data? {
        let ecdsaPublicKey = EVP_PKEY_get0_EC_KEY(publicKey)
        guard let ecdsaPublicKey else { return nil }
        
        let group = EC_KEY_get0_group(ecdsaPublicKey)
        guard let group else { return nil }
        
        let point = EC_KEY_get0_public_key(ecdsaPublicKey)
        guard let point else { return nil }
        
        let x = BN_new()
        let y = BN_new()
        defer {
            BN_free(x)
            BN_free(y)
        }
        
        if EC_POINT_get_affine_coordinates_GFp(group, point, x, y, nil) == 0 { return nil }
        
        return getDataFromOpaquePointer(x) + getDataFromOpaquePointer(y)
    }
    
    static func getCurveFromECDSAPublicKey(_ publicKey: OpaquePointer?) -> String? {
        let ecdsaPublicKey = EVP_PKEY_get0_EC_KEY(publicKey)
        guard let ecdsaPublicKey else { return nil }
        
        let group = EC_KEY_get0_group(ecdsaPublicKey)
        guard let group else { return nil }
        
        let nid = EC_GROUP_get_curve_name(group)
        
        return String(validatingUTF8: OBJ_nid2sn(nid))
    }
}
