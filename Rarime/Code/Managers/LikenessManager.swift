import Foundation
import SwiftUI

class LikenessManager: ObservableObject {
    static let shared = LikenessManager()

    @Published var rule: LikenessRule {
        didSet {
            AppUserDefaults.shared.likenessRule = rule.rawValue
        }
    }

    @Published var isRegistered: Bool {
        didSet {
            AppUserDefaults.shared.isLikenessRegistered = isRegistered
        }
    }

    @Published var faceImage: UIImage?

    init() {
        rule = .init(rawValue: AppUserDefaults.shared.likenessRule) ?? .unset
        isRegistered = AppUserDefaults.shared.isLikenessRegistered

        let imageData = try? AppKeychain.getValue(.likenessFace)
        faceImage = imageData == nil ? nil : UIImage(data: imageData!)
    }

    func setRule(_ rule: LikenessRule) {
        self.rule = rule
    }

    func setIsRegistered(_ isRegistered: Bool) {
        self.isRegistered = isRegistered
    }

    func setFaceImage(_ image: UIImage?) {
        faceImage = image
        if let imageData = image?.pngData() {
            try? AppKeychain.setValue(.likenessFace, imageData)
        } else {
            try? AppKeychain.removeValue(.likenessFace)
        }
    }

    func runRegistration() async throws {
        LoggerUtil.common.debug("Face registration is running")

        guard let faceImage else {
            throw "Face image is not initialized"
        }

        guard let foundFace = try NeuralUtils.extractFaceFromImage(faceImage) else {
            throw Errors.unknown("Face can not be detected")
        }

        let (_, grayscaleData) = try NeuralUtils.convertFaceToGrayscaleData(foundFace, TensorFlow.bionetImageBoundary)

        let model = NeuralUtils.normalizeModel(grayscaleData)

        let features = try TensorFlowManager.shared.compute(model, tfData: TensorFlow.bioNetV3)

        let zkInputs = CircuitBuilderManager.shared.bionetCircuit.inputs(grayscaleData, features, 0, 1)

        let zkWitness = try ZKUtils.bionetta(zkInputs.json)

        let zkeyPath = try await CircuitDataManager.shared.retriveZkeyPath(.likeness)

        let zkey = try Data(contentsOf: zkeyPath)

        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(zkey, zkWitness)

        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)

        let zkProof = GrothZkProof(proof: proof, pubSignals: pubSignals)

        LoggerUtil.common.debug("Face registration is finished")
    }

    func reset() {
        setRule(.unset)
        setIsRegistered(false)
        setFaceImage(nil)
    }
}
