import Alamofire
import Foundation

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var isBalanceFetching = true
        @Published var pointsBalance: PointsBalanceRaw? = nil

        func fetchBalance() async {
            isBalanceFetching = true
            defer { isBalanceFetching = false }

            if UserManager.shared.user?.userReferralCode == nil { return }

            do {
                guard let user = UserManager.shared.user else { throw "failed to get user" }
                let accessJwt = try await DecentralizedAuthManager.shared.getAccessJwt(user)

                let pointsBalance = try await UserManager.shared.fetchPointsBalance(accessJwt)
                self.pointsBalance = pointsBalance
            } catch let afError as AFError where afError.isExplicitlyCancelledError {
                return
            } catch {
                LoggerUtil.common.error("failed to fetch balance: \(error.localizedDescription, privacy: .public)")
            }
        }

        func verifyReferralCode() async {
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
