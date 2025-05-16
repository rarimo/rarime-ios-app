import Alamofire
import Foundation

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

struct PrizeScanCelebrity {
    let id, title, description, status, image, hint: String
}

class PrizeScanViewModel: ObservableObject {
    @Published var user: PrizeScanUser? = nil

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
                    // TODO: pass referral code to the backend
                    userResponse = try await guessCelebrityService.createUser(jwt: jwt)
                } else {
                    throw error
                }
            } catch {
                AlertManager.shared.emitError(.unknown("Failed to load user information"))
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

    func getExtraAttempt(jwt: JWT) async {
        do {
            let guessCelebrityService = GuessCelebrityService(ConfigManager.shared.api.pointsServiceURL)
            let _ = try await guessCelebrityService.addExtraAttempt(jwt: jwt)
            await loadUser(jwt: jwt)
        } catch {
            LoggerUtil.common.error("PrizeScan: Failed to get extra attempt: \(error, privacy: .public)")
        }
    }
}
