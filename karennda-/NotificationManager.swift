import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知許可エラー: \(error)")
            } else {
                print("通知許可: \(granted)")
            }
        }
    }

    func scheduleOneTimeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "テスト通知"
        content.body = "これは5秒後の通知です"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error)")
            } else {
                print("通知がスケジュールされました")
            }
        }
    }
}

