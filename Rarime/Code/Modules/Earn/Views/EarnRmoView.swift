import SwiftUI

private struct EarnTask: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: ImageResource
    let reward: Int
    let isCompleted: Bool
    let onTap: () -> Void
}

struct EarnRmoView: View {
    let balance: PointsBalanceRaw?
    let onClose: () -> Void
    var animation: Namespace.ID

    @State private var isInviteSheetPresented: Bool = false

    private var referralCodes: [ReferalCode] {
        balance?.referralCodes ?? []
    }

    private var usedReferralCodesCount: Int {
        referralCodes.filter { $0.status != .active }.count
    }

    private var earnTasks: [EarnTask] {
        [
            EarnTask(
                title: String(localized: "Invite others"),
                description: String(localized: "Invited: \(usedReferralCodesCount)/\(referralCodes.count)"),
                icon: .userAddLine,
                reward: Int(Rewards.invite) * referralCodes.count,
                isCompleted: referralCodes.allSatisfy { $0.status == .rewarded },
                onTap: { isInviteSheetPresented = true }
            ),
        ]
    }

    private var activeTasks: [EarnTask] {
        earnTasks.filter { !$0.isCompleted }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PullToCloseWrapperView(action: onClose) {
                GlassBottomSheet(
                    minHeight: 480,
                    maxHeight: 730,
                    maxBlur: 70,
                    background: {
                        Image(.earnBg)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                            .ignoresSafeArea()
                    }
                ) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Earn")
                                .h1()
                                .foregroundStyle(.invertedDark)
                            Text("RMO")
                                .additional1()
                                .foregroundStyle(Gradients.greenText)
                            Text("Complete various tasks and get rewarded with Rarimo tokens.")
                                .body3()
                                .foregroundStyle(.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 12)
                        }
                        HorizontalDivider()
                        Text(activeTasks.count == 1 ? "\(activeTasks.count) active task" : "\(activeTasks.count) active tasks")
                            .overline2()
                            .foregroundStyle(.textSecondary)
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(activeTasks, id: \.id) { task in
                                    EarnTaskView(task: task)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            Button(action: onClose) {
                Image(.closeFill)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(10)
                    .background(.bgComponentPrimary, in: Circle())
            }
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .dynamicSheet(isPresented: $isInviteSheetPresented) {
            InviteOthersView(referralCodes: balance?.referralCodes ?? [])
                .padding(.top, 32)
        }
    }
}

private struct EarnTaskView: View {
    let task: EarnTask

    var body: some View {
        Button(action: task.onTap) {
            VStack(alignment: .leading, spacing: 32) {
                HStack(spacing: 12) {
                    Image(task.icon)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                        .padding(10)
                        .background(.bgComponentPrimary, in: Circle())
                    Spacer()
                    HStack(spacing: 4) {
                        Text(verbatim: "+\(task.reward)")
                            .overline1()
                        Image(.rarimo)
                            .iconSmall()
                    }
                    .foregroundStyle(.invertedLight)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(.textPrimary, in: Capsule())
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(task.title)
                            .subtitle4()
                            .foregroundStyle(.textPrimary)
                        Image(.arrowRight)
                            .iconMedium()
                    }
                    Text(task.description)
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(24)
        .background(.bgSurface1, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.bgComponentPrimary, lineWidth: 1)
        }
    }
}

#Preview {
    EarnRmoView(
        balance: PointsBalanceRaw(
            amount: 12,
            isDisabled: false,
            createdAt: Int(Date().timeIntervalSince1970),
            updatedAt: Int(Date().timeIntervalSince1970),
            rank: 12,
            referralCodes: [
                ReferalCode(id: "code1", status: .active),
                ReferalCode(id: "code2", status: .awaiting),
                ReferalCode(id: "code3", status: .banned),
                ReferalCode(id: "code4", status: .consumed),
                ReferalCode(id: "code5", status: .limited),
                ReferalCode(id: "code6", status: .rewarded),
            ],
            level: 2,
            isVerified: true
        ),
        onClose: {},
        animation: Namespace().wrappedValue
    )
}
