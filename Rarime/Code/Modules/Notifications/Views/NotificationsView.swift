import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var notificationsManager: NotificationManager
    @Environment(\.managedObjectContext) var viewContext
    
    let onBack: () -> Void
    
    @State private var chosenNotification: PushNotification? = nil
    @State private var isNotificationDetailsSheetShown = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PushNotification.receivedAt, ascending: false)]) var pushNotifications: FetchedResults<PushNotification>
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .topLeading) {
                Button(action: onBack) {
                    Image(.arrowLeftSLine)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                Text("Notifications")
                    .buttonMedium()
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
            }
            if pushNotifications.isEmpty {
                Spacer()
                Text("No notifications")
                    .body4()
                    .foregroundStyle(.textSecondary)
                Spacer()
            } else {
                ScrollViewReader { scrollView in
                    List {
                        ForEach(pushNotifications, id: \.id) { pushNotification in
                            NotificationView(notification: pushNotification)
                                .listRowInsets(.init(top: 16, leading: 0, bottom: 16, trailing: 0))
                                .listSectionSeparator(.hidden, edges: .bottom)
                                .swipeActions(allowsFullSwipe: false) {
                                    Button(action: {
                                        withAnimation {
                                            delete(pushNotification)
                                        }
                                    }) {
                                        Image(.deleteBin6Line)
                                            .iconMedium()
                                            .foregroundStyle(.baseWhite)
                                    }
                                    .tint(.errorDark)
                                }
                                .onTapGesture {
                                    chosenNotification = pushNotification
                                }
                                .onDisappear {
                                    markAsRead(pushNotification)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .onAppear {
                        scrollView.scrollTo(pushNotifications.last?.id)
                    }
                }
            }
        }
        .padding([.top, .horizontal], 20)
        .onAppear {
            notificationsManager.eraceUnreadNotificationsCounter()
        }
        .onChange(of: chosenNotification) { notification in
            isNotificationDetailsSheetShown = notification != nil
        }
        .dynamicSheet(isPresented: $isNotificationDetailsSheetShown, fullScreen: true) {
            NotificationDetailsView(notification: chosenNotification!) {
                isNotificationDetailsSheetShown = false
            }
        }
    }
    
    func delete(_ notification: PushNotification) {
        viewContext.delete(notification)
        
        do {
            try viewContext.save()
            
            LoggerUtil.common.info("Push notification deleted")
        } catch {
            LoggerUtil.common.error("Error deleting push notification: \(error, privacy: .public)")
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

private struct NotificationView: View {
    let notification: PushNotification

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Text(notification.title ?? "")
                    .subtitle6()
                Spacer()
                HStack(alignment: .center, spacing: 4) {
                    if !notification.isRead {
                        Circle()
                            .fill(.textPrimary)
                            .frame(width: 8)
                    }
                    Text(notification.receivedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .caption3()
                }
            }
            .foregroundStyle(notification.isRead ? .textSecondary : .textPrimary)
            Text(notification.body ?? "")
                .body5()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
    }
}

#Preview {
    NotificationsView {}
        .environmentObject(NotificationManager.shared)
        .environment(\.managedObjectContext, NotificationManager.shared.pushNotificationContainer.viewContext)
        .onAppear {
            let context = NotificationManager.shared.pushNotificationContainer.viewContext
           
            let pushNotification = PushNotification(context: context)
            pushNotification.id = UUID()
            pushNotification.title = "Other title"
            pushNotification.body = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text"
            pushNotification.receivedAt = Date()
            pushNotification.isRead = true
           
            do {
                try context.save()
            } catch {
                LoggerUtil.common.error("Error saving test notifications: \(error, privacy: .public)")
            }
        }
}
