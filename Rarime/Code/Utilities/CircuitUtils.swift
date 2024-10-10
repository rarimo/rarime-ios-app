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
}
