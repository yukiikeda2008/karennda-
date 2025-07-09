//
//  AlarmManager.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/09.
//

import Foundation
import UserNotifications

class AlarmManager {
    static let shared = AlarmManager()
    private init() {}

    var alarms: [Alarm] = []

    func addAlarm(time: Date, label: String) {
        let id = UUID().uuidString
        let alarm = Alarm(id: id, time: time, label: label, isOn: true)
        alarms.append(alarm)
        scheduleNotification(for: alarm)
    }

    func toggleAlarm(_ alarm: Alarm, isOn: Bool) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isOn = isOn
            if isOn {
                scheduleNotification(for: alarms[index])
            } else {
                removeNotification(id: alarm.id)
            }
        }
    }

    func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = alarm.label.isEmpty ? "時間になりました" : alarm.label
        content.sound = .default

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
