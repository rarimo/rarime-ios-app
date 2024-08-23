import SwiftUI

struct NotificationView: View {
    let notification: PushNotification
    
    var body: some View {
        VStack {
            if notification.isRead {
                HStack {
                    Text(notification.title ?? "")
                        .body3()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Text(notification.receivedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .caption3()
                        .foregroundStyle(.textSecondary)
                }
                Text(notification.body ?? "")
                    .body4()
                    .foregroundStyle(.textSecondary)
                    .align()
            } else {
                HStack {
                    Text(notification.title ?? "")
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    HStack {
                        Circle()
                            .foregroundStyle(.successMain)
                            .frame(width: 8, height: 8)
                        Text(notification.receivedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .caption3()
                            .foregroundStyle(.successMain)
                    }
                }
                Text(notification.body ?? "")
                    .subtitle5()
                    .foregroundStyle(.textSecondary)
                    .align()
            }
        }
        .frame(width: 350, height: 58)
    }
}

#Preview {
    let pushNotification = PushNotification(context: NotificationManager.shared.pushNotificationContainer.viewContext)
    pushNotification.id = UUID()
    pushNotification.title = "Other notification"
    pushNotification.body = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text"
    pushNotification.receivedAt = Date()
    pushNotification.isRead = false
    
    return NotificationView(notification: pushNotification)
}
