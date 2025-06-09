import Alamofire
import Foundation
import Identity
import SwiftUI

struct FindFaceCelebrity {
    let id, title, description, image, hint, winner: String
    let status: GuessCelebrityStatus
}

struct FindFaceUser {
    let id, referralCode: String
    let referralsCount, referralsLimit: Int
    let socialShare: Bool

    let attemptsLeft, extraAttemptsLeft, totalAttemptsCount: Int
    let resetTime: TimeInterval

    let celebrity: FindFaceCelebrity
}

extension FindFaceUser {
    static func empty() -> FindFaceUser {
        FindFaceUser(
            id: "",
            referralCode: "",
            referralsCount: 0,
            referralsLimit: 0,
            socialShare: false,
            attemptsLeft: 0,
            extraAttemptsLeft: 0,
            totalAttemptsCount: 0,
            resetTime: 0,
            celebrity: FindFaceCelebrity(
                id: "",
                title: "",
                description: "",
                image: "",
                hint: "",
                winner: "",
                status: .maintenance
            )
        )
    }
}

private let FIND_FACE_REFERRAL_CODE_LENGTH = 10

class FindFaceViewModel: ObservableObject {
    static let faceThreshold = 74088185856

    @Published var user: FindFaceUser? = nil
    @Published var originalFeatures: [Float] = []
    @Published var foundFace: UIImage? = nil

    @MainActor
    func loadUser(referralCode: String? = nil) async {
        let guessCelebrityService = GuessCelebrityService(ConfigManager.shared.api.pointsServiceURL)
        var userResponse: GuessCelebrityUserResponse
        var jwt: JWT? = nil

        do {
            guard let user = UserManager.shared.user else { throw "failed to get user" }
            jwt = try await DecentralizedAuthManager.shared.getAccessJwt(user)
            userResponse = try await guessCelebrityService.getUserInformation(jwt: jwt!)
        } catch let afError as AFError where afError.isExplicitlyCancelledError {
            return
        } catch {
            do {
                guard let jwt else { throw "failed to get JWT" }
                guard let error = error as? AFError else { throw error }
                let openApiHttpCode = try error.retriveOpenApiHttpCode()
                if openApiHttpCode == HTTPStatusCode.notFound.rawValue {
                    LoggerUtil.common.info("FindFace: User is not found, creating a new user")

                    // Because referral codes can be used in different services,
                    // we check whether the code belongs to the guess celebrity service
                    let refCode = referralCode?.count == FIND_FACE_REFERRAL_CODE_LENGTH
                        ? referralCode
                        : nil

                    userResponse = try await guessCelebrityService.createUser(jwt: jwt, referredBy: refCode)
                } else {
                    throw error
                }
            } catch let afError as AFError where afError.isExplicitlyCancelledError {
                return
            } catch {
                AlertManager.shared.emitError("Failed to load user information")
                LoggerUtil.common.error("FindFace: Failed to load user information: \(error, privacy: .public)")
                return
            }
        }

        let userStatsRel = userResponse.data.relationships.userStats.data
        let userStats = userResponse.included.first(where: { $0.id == userStatsRel.id && $0.type == userStatsRel.type })

        let celebrityRel = userResponse.data.relationships.celebrity.data
        let celebrity = userResponse.included.first(where: { $0.id == celebrityRel.id && $0.type == celebrityRel.type })

        user = FindFaceUser(
            id: userResponse.data.id,
            referralCode: userResponse.data.attributes.referralCode,
            referralsCount: userResponse.data.attributes.referralsCount,
            referralsLimit: userResponse.data.attributes.referralsLimit,
            socialShare: userResponse.data.attributes.socialShare,

            attemptsLeft: userStats?.attributes.attemptsLeft ?? 0,
            extraAttemptsLeft: userStats?.attributes.extraAttemptsLeft ?? 0,
            totalAttemptsCount: userStats?.attributes.totalAttemptsCount ?? 0,
            resetTime: userStats?.attributes.resetTime ?? 0,

            celebrity: FindFaceCelebrity(
                id: celebrity?.id ?? "",
                title: celebrity?.attributes.title ?? "",
                description: celebrity?.attributes.description ?? "",
                image: celebrity?.attributes.image ?? "",
                hint: celebrity?.attributes.hint ?? "",
                winner: celebrity?.attributes.winner ?? "",
                status: celebrity?.attributes.status ?? .maintenance
            )
        )
    }

    func getExtraAttempt() async throws {
        guard let user = UserManager.shared.user else { throw "failed to get user" }
        let jwt = try await DecentralizedAuthManager.shared.getAccessJwt(user)

        let guessCelebrityService = GuessCelebrityService(ConfigManager.shared.api.pointsServiceURL)
        let _ = try await guessCelebrityService.addExtraAttempt(jwt: jwt)
        await loadUser()
    }

    func submitGuess(image: UIImage) async throws -> Bool {
        guard let user = UserManager.shared.user else { throw "failed to get user" }
        let jwt = try await DecentralizedAuthManager.shared.getAccessJwt(user)

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
        await loadUser()

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

        let guessInputs = CircuitBuilderManager.shared.bionetCircuit.inputs(grayscaleData, originalFeatures, nonce, inputAddress, FindFaceViewModel.faceThreshold)
        let zkProof = try await LikenessManager.shared.generateBionettaProof(guessInputs.json, downloadProgress)

        let guessCalldata = try IdentityCallDataBuilder().buildGuessCelebrityClaimRewardCalldata(address, zkPointsJSON: zkProof.json)

        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(guessCalldata, ConfigManager.shared.api.guessCelebrityGameContractAddress)

        LoggerUtil.common.info("Claim reward EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")

        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
}
