@testable import Rarime
import XCTest

final class GuessGameParamCalculation: XCTestCase {
    func testCalculateGameParameters() async {
        try! await calculateFeaturesToCompare()
        try! await calculateFeaturesToHash()
    }

    func calculateFeaturesToCompare() async throws {
        let testFaceImage = UIImage(resource: .testFace)

        let foundFace = try! NeuralUtils.extractFaceFromImage(testFaceImage)

        LoggerUtil.common.info("Downloading face recognition model...")

        let faceRecognitionTFLilePath = try! await DownloadableDataManager.shared.retriveDownloadbleFilePath(.faceRecognitionTFLite)

        LoggerUtil.common.info("Face recognition model downloaded")

        let faceRecognitionTFLile = try! Data(contentsOf: faceRecognitionTFLilePath)

        let (_, rgbData) = try! NeuralUtils.convertFaceToRgb(foundFace!, TensorFlow.faceRecognitionImageBoundary)

        let normalizedInput = NeuralUtils.normalizeModel(rgbData)

        let features = try! TensorFlowManager.shared.compute(normalizedInput, tfData: faceRecognitionTFLile)

        LoggerUtil.common.info("Features to compare: \(features.json.utf8)")
    }

    func calculateFeaturesToHash() async throws {
        let testFaceImage = UIImage(resource: .testFace)

        let foundFace = try NeuralUtils.extractFaceFromImage(testFaceImage)

        let (_, grayscaleData) = try NeuralUtils.convertFaceToGrayscaleData(foundFace!, TensorFlow.bionetImageBoundary)

        let model = NeuralUtils.normalizeModel(grayscaleData)

        let features = try TensorFlowManager.shared.compute(model, tfData: TensorFlow.bioNetV3)

        LoggerUtil.common.info("Features to hash: \(features.json.utf8)")

        let zkInputs = CircuitBuilderManager.shared.bionetCircuit.inputs(grayscaleData, features, BN(0), BN(0))

        LoggerUtil.common.info("Generating ZK proof...")

        let zkProof = try await generateBionettaProof(zkInputs.json)

        let featureHash = try BN(dec: zkProof.pubSignals[0])

        LoggerUtil.common.info("Feature hash: \(featureHash.fullHex())")
    }

    func generateBionettaProof(
        _ inputs: Data,
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> GrothZkProof {
        LoggerUtil.common.info("Downloading zkey...")

        let zkeyPath = try await DownloadableDataManager.shared.retriveZkeyPath(.likeness, downloadProgress)

        LoggerUtil.common.info("Zkey downloaded")

        let zkey = try Data(contentsOf: zkeyPath)

        let zkWitness = try ZKUtils.bionetta(inputs)

        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(zkey, zkWitness)

        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)

        return GrothZkProof(proof: proof, pubSignals: pubSignals)
    }
}
