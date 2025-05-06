import Foundation
import SwiftUI

import Identity

import Web3

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
        LoggerUtil.common.info("Face registration is running")

        guard let faceImage else {
            throw "Face image is not initialized"
        }

        guard let foundFace = try NeuralUtils.extractFaceFromImage(faceImage) else {
            throw Errors.unknown("Face can not be detected")
        }

        let address = try UserManager.shared.generateNullifierForEvent(FaceRegistryContract.eventId)

        let faceRegistryContract = try FaceRegistryContract()

        if try await faceRegistryContract.isUserRegistered(address) {
            LoggerUtil.common.info("Face registration is irrelevant")

            return
        }

        let nonceBigUint = try await faceRegistryContract.getVerificationNonce(address)
        let nonce = try BN(dec: nonceBigUint.description)

        let (_, grayscaleData) = try NeuralUtils.convertFaceToGrayscaleData(foundFace, TensorFlow.bionetImageBoundary)

        let model = NeuralUtils.normalizeModel(grayscaleData)

        let features = try TensorFlowManager.shared.compute(model, tfData: TensorFlow.bioNetV3)

        let zkInputs = try CircuitBuilderManager.shared.bionetCircuit.inputs(grayscaleData, features, nonce, BN(hex: address))

        let zkProof = try await generateBionettaProof(zkInputs.json)

        let registerUserCalldata = try IdentityCallDataBuilder().buildFaceRegistryRegisterUser(zkProof.json)

        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.likenessRegistry(registerUserCalldata, ConfigManager.shared.api.registrationSimpleContractAddress, false)

        LoggerUtil.common.info("Face register EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")

        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }

    func generateBionettaProof(_ inputs: Data) async throws -> GrothZkProof {
        let zkWitness = try ZKUtils.bionetta(inputs)

        let zkeyPath = try await CircuitDataManager.shared.retriveZkeyPath(.likeness)

        let zkey = try Data(contentsOf: zkeyPath)

        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(zkey, zkWitness)

        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)

        return GrothZkProof(proof: proof, pubSignals: pubSignals)
    }

    func reset() {
        setRule(.unset)
        setIsRegistered(false)
        setFaceImage(nil)
    }
}
