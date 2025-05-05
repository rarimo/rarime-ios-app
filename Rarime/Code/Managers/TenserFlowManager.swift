import Foundation

import TensorFlowLite

class TenserFlowManager {
    static let shared = TenserFlowManager()

    func compute(_ inputs: [Float], tfData: Data) throws -> [Float] {
        let interpreter = try Interpreter(modelData: tfData)

        try interpreter.allocateTensors()

        var inputsData = Data()
        for input in inputs {
            inputsData.append(contentsOf: withUnsafeBytes(of: input) { Data($0) })
        }

        try interpreter.copy(inputsData, toInputAt: 0)

        try interpreter.invoke()

        let outputTensor = try interpreter.output(at: 0)

        let outputData = outputTensor.data

        var outputArrayFloat = [Float](repeating: 0, count: outputData.count / MemoryLayout<Float>.stride)
        _ = outputArrayFloat.withUnsafeMutableBytes { outputData.copyBytes(to: $0) }

        let sumOfSquare = outputArrayFloat.reduce(0) { $0 + $1 * $1 }

        return outputArrayFloat.map { $0 / sqrt(sumOfSquare) }
    }
}
