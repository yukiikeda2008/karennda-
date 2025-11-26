//
//  NotificationManager.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { _,_ in }
    }

    // 週次繰り返し: DoseSchedule x 含まれる曜日
    func scheduleWeekly(for med: Medication) {
        for s in med.schedules {
            for w in s.daysOfWeek {
                let id = "\(s.id.uuidString)-\(w)"  // ← 統一ルール
                var comps = DateComponents()
                comps.weekday = w
                comps.hour = s.hour
                comps.minute = s.minute
                comps.second = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

                let content = UNMutableNotificationContent()
                content.title = med.name
                content.body = "服用の時間です（\(String(format: "%.0f", s.quantity))）"
                content.sound = .default

                let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(req)
            }
        }
    }

    // 一括取消（削除や編集のとき）
    func cancelWeekly(for med: Medication) {
        let ids = med.schedules.flatMap { s in
            (1...7).map { "\(s.id.uuidString)-\($0)" }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}

