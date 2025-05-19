import Alamofire
import Foundation
import Identity
import SwiftUI

struct PrizeScanUser {
    let id, referralCode: String
    let referralsCount, referralsLimit: Int
    let socialShare: Bool

    let attemptsLeft, extraAttemptsLeft, totalAttemptsCount: Int
    let resetTime: TimeInterval

    let celebrity: PrizeScanCelebrity?
}

extension PrizeScanUser {
    static func empty() -> PrizeScanUser {
        PrizeScanUser(
            id: "",
            referralCode: "",
            referralsCount: 0,
            referralsLimit: 0,
            socialShare: false,
            attemptsLeft: 0,
            extraAttemptsLeft: 0,
            totalAttemptsCount: 0,
            resetTime: 0,
            celebrity: PrizeScanCelebrity(
                id: "",
                title: "",
                description: "",
                status: "",
                image: "",
                hint: ""
            )
        )
    }
}

private let PRIZE_SCAN_REFERRAL_CODE_LENGTH = 10

struct PrizeScanCelebrity {
    let id, title, description, status, image, hint: String
}

class PrizeScanViewModel: ObservableObject {
    @Published var user: PrizeScanUser? = nil
    @Published var originalFeatures: [Float] = []
    @Published var foundFace: UIImage? = nil

    @MainActor
    func loadUser(jwt: JWT, referralCode: String? = nil) async {
        let guessCelebrityService = GuessCelebrityService(ConfigManager.shared.api.pointsServiceURL)
        var userResponse: GuessCelebrityUserResponse

        do {
            userResponse = try await guessCelebrityService.getUserInformation(jwt: jwt)
        } catch {
            do {
                guard let error = error as? AFError else { throw error }
                let openApiHttpCode = try error.retriveOpenApiHttpCode()
                if openApiHttpCode == HTTPStatusCode.notFound.rawValue {
                    LoggerUtil.common.info("PrizeScan: User is not found, creating a new user")

                    // Because referral codes can be used in different services,
                    // we check whether the code belongs to the guess celebrity service
                    let refCode = referralCode?.count == PRIZE_SCAN_REFERRAL_CODE_LENGTH
                        ? referralCode
                        : nil

                    userResponse = try await guessCelebrityService.createUser(jwt: jwt, referredBy: refCode)
                } else {
                    throw error
                }
            } catch {
                AlertManager.shared.emitError("Failed to load user information")
                LoggerUtil.common.error("PrizeScan: Failed to load user information: \(error, privacy: .public)")
                return
            }
        }

        let userStatsRel = userResponse.data.relationships.userStats.data
        let userStats = userResponse.included.first(where: { $0.id == userStatsRel.id && $0.type == userStatsRel.type })

        let celebrityRel = userResponse.data.relationships.celebrity.data
        let celebrity = userResponse.included.first(where: { $0.id == celebrityRel.id && $0.type == celebrityRel.type })

        user = PrizeScanUser(
            id: userResponse.data.id,
            referralCode: userResponse.data.attributes.referralCode,
            referralsCount: userResponse.data.attributes.referralsCount,
            referralsLimit: userResponse.data.attributes.referralsLimit,
            socialShare: userResponse.data.attributes.socialShare,

            attemptsLeft: userStats?.attributes.attemptsLeft ?? 0,
            extraAttemptsLeft: userStats?.attributes.extraAttemptsLeft ?? 0,
            totalAttemptsCount: userStats?.attributes.totalAttemptsCount ?? 0,
            resetTime: userStats?.attributes.resetTime ?? 0,

            celebrity: PrizeScanCelebrity(
                id: celebrity?.id ?? "",
                title: celebrity?.attributes.title ?? "",
                description: celebrity?.attributes.description ?? "",
                status: celebrity?.attributes.status ?? "",
                image: celebrity?.attributes.image ?? "",
                hint: celebrity?.attributes.hint ?? ""
            )
        )
    }

    func getExtraAttempt(jwt: JWT) async throws {
        let guessCelebrityService = GuessCelebrityService(ConfigManager.shared.api.pointsServiceURL)
        let _ = try await guessCelebrityService.addExtraAttempt(jwt: jwt)
        await loadUser(jwt: jwt)
    }

    func submitGuess(jwt: JWT, image: UIImage) async throws -> Bool {
        guard let foundFace = try NeuralUtils.extractFaceFromImage(image) else {
            throw Errors.unknown("Face can not be detected")
        }

        self.foundFace = foundFace

        let faceRecognitionTFLilePath = try await DownloadableDataManager.shared.retriveDownloadbleFilePath(.faceRecognitionTFLite)

        let faceRecognitionTFLile = try Data(contentsOf: faceRecognitionTFLilePath)

        let (_, rgbData) = try NeuralUtils.convertFaceToRgb(foundFace, TensorFlow.faceRecognitionImageBoundary)

        let normalizedInput = NeuralUtils.normalizeModel(rgbData)

        let features = try TensorFlowManager.shared.compute(normalizedInput, tfData: faceRecognitionTFLile)

        let guessCelebrityService = GuessCelebrityService(ConfigManager.shared.api.pointsServiceURL)
        let guessResponse = try await guessCelebrityService.submitCelebrityGuess(jwt, features)
        await loadUser(jwt: jwt)

        let isSuccess = guessResponse.data.attributes.success
        if isSuccess {
            guard let originalFeatureVector = guessResponse.data.attributes.originalFeatureVector else {
                throw Errors.unknown("Original feature vector is absent")
            }

            originalFeatures = originalFeatureVector
        }

        return isSuccess
    }

    func claimReward(_ downloadProgress: @escaping (Progress) -> Void) async throws {
        guard let address = UserManager.shared.ethereumAddress else {
            throw Errors.unknown("User is not initialized")
        }

        guard let foundFace else {
            throw Errors.unknown("Face can not be detected")
        }

        let (_, grayscaleData) = try NeuralUtils.convertFaceToGrayscaleData(foundFace, TensorFlow.faceRecognitionImageBoundary)

        let inputAddress = try BN(hex: address)

        let faceRegistryContract = try FaceRegistryContract()
        let nonceBigUint = try await faceRegistryContract.getVerificationNonce(inputAddress.fullHex())
        let nonce = try BN(dec: nonceBigUint.description)

        let guessInputs = CircuitBuilderManager.shared.bionetCircuit.inputs(grayscaleData, originalFeatures, nonce, inputAddress)
        let zkProof = try await LikenessManager.shared.generateBionettaProof(guessInputs.json, downloadProgress)

        let guessCalldata = try IdentityCallDataBuilder().buildGuessCelebrityClaimRewardCalldata(address, zkPointsJSON: zkProof.json)

        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(guessCalldata)

        LoggerUtil.common.info("Claim reward EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")

        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
}
