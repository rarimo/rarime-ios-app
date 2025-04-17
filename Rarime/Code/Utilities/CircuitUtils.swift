import BigInt
import Foundation

class CircuitUtils {
    static func byteArrayToBits(_ bytes: Data) -> [Int64] {
        var bits = [Int64]()
        for byte in bytes {
            for i in 0..<8 {
                bits.append(Int64((byte >> (7 - i)) & 1))
            }
        }
        return bits
    }
    
    static func smartChunking(_ x: BN, chunksNumber: Int) -> [BN] {
        var value = x
        
        var result: [BN] = []
        
        let mod = BN(1).lshift(64)
        
        for _ in 0..<chunksNumber {
            let chunk = value.mod(mod)
            
            result.append(chunk)
            
            value = value.div(mod)
        }
        
        return result
    }
    
    static func smartChunking2(_ bytes: Data, _ blockNumber: UInt64, _ smartChunking2BlockSize: UInt64) -> [Int64] {
        let bits = byteArrayToBits(bytes)
            
        let dataBitsNumber = UInt64(bits.count + 1 + 64)
        let dataBlockNumber = dataBitsNumber / smartChunking2BlockSize + 1
        let zeroDataBitsNumber = dataBlockNumber * smartChunking2BlockSize - dataBitsNumber
            
        var result = [Int64]()
        result.append(contentsOf: bits)
        result.append(1)
            
        for _ in 0..<zeroDataBitsNumber {
            result.append(0)
        }
            
        var bitsNumberBytes = [UInt8](repeating: 0, count: 8)
        let bitsCount = UInt64(bits.count)
        withUnsafeBytes(of: bitsCount.bigEndian) { buffer in
            bitsNumberBytes = Array(buffer)
        }
            
        let bitsNumber = byteArrayToBits(Data(bitsNumberBytes))
        result.append(contentsOf: bitsNumber)
            
        if dataBlockNumber >= blockNumber {
            return result
        }
            
        let restBlocksNumber = blockNumber - dataBlockNumber
            
        for _ in 0..<(restBlocksNumber * smartChunking2BlockSize) {
            result.append(0)
        }
            
        return result
    }
    
    static func calculateSmartChunkingNumber(_ bytesNumber: Int) -> Int {
        return bytesNumber == 2048 ? 32 : 64
    }
    
    static func SmartBNToArray120(_ n: UInt, _ k: UInt, _ x: BN) -> [BN] {
        var mod = BN(1)
        for _ in 0..<n {
            mod = mod.mul(BN(2))
        }
            
        var returnData: [BN] = []
        var mut_x = x
        for _ in 0..<k {
            returnData.append(mut_x.mod(mod))
                
            mut_x = mut_x.div(mod)
        }
            
        return returnData
    }
    
    static func RSABarrettReductionParam(_ n: BN, _ n_bits: UInt) -> [BN] {
        var chunk_number = n_bits / 120
        if n_bits % 120 != 0 {
            chunk_number += 1
        }
            
        let base_x = BN(2).exp(BN((n_bits + 2) * 2))
            
        return SmartBNToArray120(120, chunk_number, base_x.div(n))
    }
    
    static func splitEmptyData(_ data: Data) -> [BN] {
        let n_bits = data.count * 8
        
        var chunk_number = n_bits / 120
        if n_bits % 120 != 0 {
            chunk_number += 1
        }
            
        return SmartBNToArray120(120, UInt(chunk_number), BN(0))
    }
        
    static func splitBy120Bits(_ data: Data) -> [BN] {
        var chunk_number = (data.count * 8) / 120
        if (data.count * 8) % 120 != 0 {
            chunk_number += 1
        }
            
        return SmartBNToArray120(120, UInt(chunk_number), BN(data))
    }
}
