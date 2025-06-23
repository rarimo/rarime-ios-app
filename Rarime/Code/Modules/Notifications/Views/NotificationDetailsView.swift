import SwiftUI

struct NotificationDetailsView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    
    let notification: PushNotification
    
    let onClose: () -> Void
    
    @State private var isCheckingClaimable = true
    @State private var notificationEventId = ""
    @State private var isClaiming = false
    
    var body: some View {
        VStack(spacing: 12) {
            AppIconButton(icon: .closeFill, action: onClose)
                .padding([.top, .trailing], 20)
                .frame(maxWidth: .infinity, alignment: .trailing)
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(notification.title ?? "")
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                    Text(notification.receivedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .caption2()
                        .foregroundStyle(.textSecondary)
                }
                ScrollView {
                    Text(notification.body ?? "")
                        .body4()
                        .foregroundStyle(.textSecondary)
                        .align()
                }
            }
            .padding(.horizontal, 20)
            Spacer()
            if isCheckingClaimable {
                ProgressView()
            }
            if !notificationEventId.isEmpty {
                AppButton(text: "Reserve", action: claimRewards)
                    .controlSize(.large)
                    .disabled(isClaiming)
                    .padding(.horizontal, 20)
            }
        }
        .onAppear(perform: checkClaimable)
    }
    
    func claimRewards() {
        isClaiming = true
        
        Task { @MainActor in
            defer { isClaiming = false }
            
            do {
                let points = Points(ConfigManager.shared.general.appApiURL)
                
                let _ = try await points.claimPointsForEvent(self.notificationEventId)
                
                self.notificationEventId = ""
                
                AlertManager.shared.emitSuccess("Reward claimed successfully")
            } catch {
                LoggerUtil.common.error("Error claiming: \(error)")
                
                AlertManager.shared.emitError(.unknown("Error while trying to claim reward"))
            }
        }
    }
    
    func checkClaimable() {
        Task { @MainActor in
            defer { isCheckingClaimable = false }
            
            guard let content = notification.content else { return }
            
            guard let user = userManager.user else { return }

            do {
                let claimableNotificationContent = try JSONDecoder().decode(ClaimableNotificationContent.self, from: content.data(using: .utf8) ?? Data())
                
                let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
                
                let points = Points(ConfigManager.shared.general.appApiURL)
                
                let eventResponse = try await points.listEvents(
                    accessJwt,
                    filterStatus: [EventStatuses.fulfilled.rawValue],
                    filterMetaStaticName: [claimableNotificationContent.eventName]
                )
                
                if eventResponse.data.isEmpty {
                    return
                }
                
                notificationEventId = eventResponse.data[0].id
            } catch {
                LoggerUtil.common.error("Error checking claimable: \(error)")
            }
        }
    }
}

#Preview {
    let pushNotification = PushNotification(
        context: NotificationManager.shared.pushNotificationContainer.viewContext
    )
    pushNotification.id = UUID()
    pushNotification.title = "Other title"
    pushNotification.body = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text"
    pushNotification.receivedAt = Date()
    pushNotification.isRead = false
    
    return ZStack {}
        .dynamicSheet(isPresented: .constant(true), fullScreen: true) {
            NotificationDetailsView(notification: pushNotification) {}
                .environmentObject(UserManager())
                .environmentObject(DecentralizedAuthManager())
        }
}
