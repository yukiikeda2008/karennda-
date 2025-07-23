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
    
    func scheduleNotification(at date: Date, title: String, body: String) -> String? {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let interval = date.timeIntervalSinceNow
        let trigget: UNNotificationTrigger
        if interval > 60 {
            var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            comps.second = 0
            trigget = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        } else{
            trigget = UNTimeIntervalNotificationTrigger(timeInterval: max(interval,1), repeats: false)
        }
        
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigget)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let err = error {
                print("erron", err)
            } else {
                //デバック用：保留中リクエスト一覧を出力
                UNUserNotificationCenter.current().getPendingNotificationRequests { request in
                    print("▶︎ Pending Requests:", request.map(\.identifier))
                }
            }
        }
        return id
    }
}

