import Alamofire
import Foundation

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var currentWidgetIndex = 0

        @Published var isBalanceFetching = true
        @Published var pointsBalance: PointsBalanceRaw? = nil
        @Published var hasBalance = AppUserDefaults.shared.hasPointsBalance {
            didSet {
                AppUserDefaults.shared.hasPointsBalance = hasBalance
            }
        }

        @MainActor
        func fetchBalance() async {
            isBalanceFetching = true
            defer { isBalanceFetching = false }

            do {
                guard let user = UserManager.shared.user else { throw "failed to get user" }
                let accessJwt = try await DecentralizedAuthManager.shared.getAccessJwt(user)

                let pointsBalance = try await UserManager.shared.fetchPointsBalance(accessJwt)
                self.pointsBalance = pointsBalance
            } catch let afError as AFError where afError.isExplicitlyCancelledError {
                return
            } catch {
                if let error = error as? AFError,
                   let openApiHttpCode = try? error.retriveOpenApiHttpCode(),
                   openApiHttpCode == HTTPStatusCode.notFound.rawValue
                {
                    LoggerUtil.common.info("User has no points balance, attempting to create balance with referral code")
                    await createBalanceWithReferralCode()
                } else {
                    LoggerUtil.common.error("Failed to fetch points balance: \(error.localizedDescription, privacy: .public)")
                }
            }

            let balanceAmount = pointsBalance?.amount ?? 0
            if !hasBalance && balanceAmount > 0 {
                hasBalance = true
            }
        }

        private func createBalanceWithReferralCode() async {
            let POINTS_REFERRAL_CODE_LENGTH = 11
            var referralCode = ConfigManager.shared.api.defaultReferralCode
            if let deferredReferralCode = UserManager.shared.user?.deferredReferralCode,
               !deferredReferralCode.isEmpty,
               deferredReferralCode.count == POINTS_REFERRAL_CODE_LENGTH
            {
                referralCode = deferredReferralCode
            }

            await attemptToCreateBalance(with: referralCode, fallback: ConfigManager.shared.api.defaultReferralCode)
        }

        private func attemptToCreateBalance(with referralCode: String, fallback: String) async {
            do {
                try await createBalance(referralCode)
            } catch let afError as AFError where afError.isExplicitlyCancelledError {
                return
            } catch {
                LoggerUtil.common.error("Failed to verify referral code: \(error.localizedDescription, privacy: .public)")
                if referralCode != fallback {
                    await attemptToCreateBalance(with: fallback, fallback: fallback)
                }
            }
        }

        private func createBalance(_ code: String) async throws {
            guard let user = UserManager.shared.user else { throw "user is not initalized" }
            let accessJwt = try await DecentralizedAuthManager.shared.getAccessJwt(user)

            let pointsSvc = Points(ConfigManager.shared.api.pointsServiceURL)
            let result = try await pointsSvc.createPointsBalance(
                accessJwt,
                code
            )

            UserManager.shared.user?.userReferralCode = code
            LoggerUtil.common.info("User verified code: \(code, privacy: .public)")

            pointsBalance = PointsBalanceRaw(
                id: result.data.id,
                amount: result.data.attributes.amount,
                isDisabled: result.data.attributes.isDisabled,
                createdAt: result.data.attributes.createdAt,
                updatedAt: result.data.attributes.updatedAt,
                rank: result.data.attributes.rank,
                referralCodes: result.data.attributes.referralCodes,
                level: result.data.attributes.level,
                isVerified: result.data.attributes.isVerified
            )
        }
    }
}
