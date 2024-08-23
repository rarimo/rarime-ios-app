import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var notificationsManager: NotificationManager
    @Environment(\.managedObjectContext) var viewContext
    
    let onBack: () -> Void
    
    @FetchRequest(sortDescriptors: []) var pushNotifications: FetchedResults<PushNotification>
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Button(action: onBack) {
                    Image(Icons.caretLeft)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                Text("Notifications")
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity)
            }
            if pushNotifications.isEmpty {
                Spacer()
                Text("No notifications")
                    .body3()
                    .foregroundStyle(.textSecondary)
                Spacer()
            } else {
                ScrollViewReader { scrollView in
                    List {
                        ForEach(pushNotifications, id: \.id) { pushNotification in
                            NotificationView(notification: pushNotification)
                                .onDisappear {
                                    markAsRead(pushNotification)
                                }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                    .onAppear {
                        scrollView.scrollTo(pushNotifications.last?.id)
                    }
                }
                Spacer()
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .onAppear {
            notificationsManager.eraceUnreadNotificationsCounter()
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let pushNotification = pushNotifications[index]
            
            viewContext.delete(pushNotification)

            do {
                try viewContext.save()
                
                LoggerUtil.common.info("Push notification deleted")
            } catch {
                LoggerUtil.common.error("Error deleting push notification: \(error, privacy: .public)")
            }
        }
    }
    
    func markAsRead(_ notification: PushNotification) {
        if notification.isRead {
            return
        }
        
        notification.isRead = true
        
        do {
            try viewContext.save()
            
            LoggerUtil.common.info("Push notification marked as read")
        } catch {
            LoggerUtil.common.error("Error marking push notification as read: \(error, privacy: .public)")
        }
    }
}

#Preview {
    NotificationsView {}
        .environmentObject(NotificationManager.shared)
}
