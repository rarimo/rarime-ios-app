import SwiftUI

struct ClaimRewardsView: View {
    @EnvironmentObject var userManager: UserManager

    let balance: PointsBalance
    let onBack: () -> Void

    @State private var amount = ""
    @State private var amountErrorMessage = ""

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 24) {
                Button(action: onBack) {
                    Image(Icons.caretLeft)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Claim RMO")
                        .subtitle2()
                        .foregroundStyle(.textPrimary)
                    Text("From a reserved pool to a wallet")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                claimCard
            }
            .padding(20)
            Spacer()
            VStack(spacing: 8) {
                Text("Claiming tokens results in a downgrade on the leaderboard")
                    .body4()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
                    .frame(maxWidth: 220)
                AppButton(text: "Claim", action: {})
                    .controlSize(.large)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(.backgroundPure)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPrimary)
    }

    private var claimCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    BalanceRow(
                        direction: String(localized: "From"),
                        label: String(localized: "Reserved"),
                        balance: balance.amount
                    )
                    HorizontalDivider().padding(.leading, 56)
                    BalanceRow(
                        direction: String(localized: "To"),
                        label: String(localized: "Balance"),
                        balance: userManager.balance
                    )
                }
                .padding(16)
                .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 8))
                AppTextField(
                    text: $amount,
                    errorMessage: $amountErrorMessage,
                    label: String(localized: "Claim amount"),
                    placeholder: String(localized: "Enter amount"),
                    keyboardType: .decimalPad,
                    action: {
                        HStack(spacing: 16) {
                            VerticalDivider()
                            Button(action: {}) {
                                Text("MAX")
                                    .buttonMedium()
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                        .frame(height: 20)
                    }
                )
            }
        }
    }
}

private struct BalanceRow: View {
    let direction: String
    let label: String
    let balance: Double

    var body: some View {
        HStack(spacing: 16) {
            Text(direction)
                .buttonMedium()
                .foregroundStyle(.textSecondary)
                .frame(width: 40, alignment: .leading)
            VerticalDivider().frame(height: 20)
            Text(label)
                .body3()
                .foregroundStyle(.textPrimary)
            Spacer()
            Text("\(balance.formatted()) RMO")
                .subtitle5()
                .foregroundStyle(.textPrimary)
        }
    }
}

#Preview {
    ClaimRewardsView(
        balance: PointsBalance(
            id: "42beAoalsOSLals3",
            amount: 12,
            rank: 16,
            level: 2,
            activeCodes: ["zgsScguZ", "jerUsmac"],
            activatedCodes: ["rCx18MZ4"],
            usedCodes: ["73k3bdYaFWM", "9csIL7dW65m"]
        ),
        onBack: {}
    )
    .environmentObject(UserManager())
}
