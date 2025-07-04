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

    @Published var isLoading: Bool = false

    @Published var isRuleUpdating: Bool = false

    init() {
        isLoading = true

        rule = .unset
        isRegistered = false

        let imageData = try? AppKeychain.getValue(.likenessFace)
        faceImage = imageData == nil ? nil : UIImage(data: imageData!)

        postInitialization()
    }

    func postInitialization() {
        Task { @MainActor in
            do {
                isRegistered = try await isUserRegistered()
                rule = try await getRule()

                isLoading = false
            } catch {
                LoggerUtil.common.error("Failed to init likenessManager: \(error)")
            }
        }
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
            throw LikenessManagerError.faceImageNotInitialized
        }

        guard let foundFace = try NeuralUtils.extractFaceFromImage(faceImage) else {
            throw NeuralUtilsError.faceNotDetected
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

        let relayer = Relayer(ConfigManager.shared.general.appApiURL)
        let response = try await relayer.likenessRegistry(registerUserCalldata)

        LoggerUtil.common.info("Face register EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")

        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)

        try await updateRule()
    }

    func updateRule() async throws {
        let address = try UserManager.shared.generateNullifierForEvent(FaceRegistryContract.eventId)

        let faceRegistryContract = try FaceRegistryContract()

        let nonceBigUint = try await faceRegistryContract.getVerificationNonce(address)

        guard let user = UserManager.shared.user else {
            throw UserManagerError.userNotInitialized
        }

        let zkInputs = CircuitBuilderManager.shared.faceRegistryNoInclusionCircuit.inputs(
            eventId: FaceRegistryContract.eventId,
            nonce: nonceBigUint.description,
            privateKey: BN(user.secretKey).dec()
        )

        let zkProof = try await generateFaceRegistryNoInclusionProof(zkInputs.json)

        let updateRuleCalldata = try IdentityCallDataBuilder().buildFaceRegistryUpdateRule(
            rule.rawValue.description,
            zkPointsJSON: zkProof.json
        )

        let relayer = Relayer(ConfigManager.shared.general.appApiURL)
        let response = try await relayer.likenessRegistry(updateRuleCalldata)

        LoggerUtil.common.info("Update face rule EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")

        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }

    func isUserRegistered() async throws -> Bool {
        if AppUserDefaults.shared.isLikenessRegistered {
            return true
        }

        let address = try UserManager.shared.generateNullifierForEvent(FaceRegistryContract.eventId)

        let faceRegistryContract = try FaceRegistryContract()

        let isUserRegistered = try await faceRegistryContract.isUserRegistered(address)

        AppUserDefaults.shared.isLikenessRegistered = isUserRegistered

        return isUserRegistered
    }

    func getRule() async throws -> LikenessRule {
        if AppUserDefaults.shared.likenessRule != LikenessRule.unset.rawValue {
            return LikenessRule(rawValue: AppUserDefaults.shared.likenessRule) ?? .unset
        }

        let address = try UserManager.shared.generateNullifierForEvent(FaceRegistryContract.eventId)

        let faceRegistryContract = try FaceRegistryContract()

        let rawRule = try await faceRegistryContract.getRule(address)

        guard let rawRuleValue = Int(rawRule.description) else {
            throw LikenessManagerError.invalidRuleFormat
        }

        guard let rule = LikenessRule(rawValue: rawRuleValue) else {
            throw LikenessManagerError.invalidRuleValue
        }

        AppUserDefaults.shared.likenessRule = rawRuleValue

        return rule
    }

    func generateBionettaProof(
        _ inputs: Data,
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> GrothZkProof {
        let zkeyPath = try await DownloadableDataManager.shared.retriveZkeyPath(.likeness, downloadProgress)
        let zkey = try Data(contentsOf: zkeyPath)

        let zkWitness = try ZKUtils.bionetta(inputs)

        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(zkey, zkWitness)

        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)

        return GrothZkProof(proof: proof, pubSignals: pubSignals)
    }

    func generateFaceRegistryNoInclusionProof(_ inputs: Data) async throws -> GrothZkProof {
        let zkWitness = try ZKUtils.calcWtns_faceRegistryNoInclusion(Circuits.faceRegistryNoInclusionDat, inputs)

        let (proofJson, pubSignalsJson) = try ZKUtils.groth16FaceRegistryNoInclusion(zkWitness)

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

enum LikenessManagerError: Error {
    case faceImageNotInitialized
    case invalidRuleFormat
    case invalidRuleValue

    var localizedDescription: String {
        switch self {
        case .faceImageNotInitialized:
            return "Face image is not initialized"
        case .invalidRuleFormat:
            return "Invalid rule format"
        case .invalidRuleValue:
            return "Invalid rule value"
        }
    }
}
