import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var notificationsManager: NotificationManager
    @Environment(\.managedObjectContext) var viewContext
    
    let onBack: () -> Void
    
    @State private var chosenNotification: PushNotification? = nil
    @State private var isNotificationSheetPresented = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PushNotification.receivedAt, ascending: false)]) var pushNotifications: FetchedResults<PushNotification>
    
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
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    chosenNotification = pushNotification
                                }
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
        .onChange(of: chosenNotification) { notification in
            isNotificationSheetPresented = notification != nil
        }
        .dynamicSheet(isPresented: $isNotificationSheetPresented, fullScreen: true) {
            NotificationSheetView(notification: chosenNotification!) {
                isNotificationSheetPresented = false
            }
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
