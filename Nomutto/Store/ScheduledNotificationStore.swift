//
//  ScheduledNotificationStore.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import Foundation

struct ScheduledNotificationStore {
    static let shared = ScheduledNotificationStore()
    private let key = "scheduledNotifications"
    
    func save(_ notif: ScheduledNotification) {
        var list = loadAll()
        list.append(notif)
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadAll() -> [ScheduledNotification] {
        guard
            let data = UserDefaults.standard.data (forKey: key) ,
            let arr = try? JSONDecoder () .decode([ScheduledNotification].self, from: data)
        else {
            return []
        }
        return arr
    }
    
    func delete(id: String) {
        var list = loadAll()
        list.removeAll { $0.id == id }
        if let data = try? JSONEncoder ().encode (list) {
            UserDefaults.standard.set(data, forKey: key)
        }
        
    }
    
}
