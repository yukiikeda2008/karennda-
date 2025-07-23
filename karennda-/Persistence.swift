//
//  Persistence.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/16.
//

import Foundation

struct Persistence {
    static let shared = Persistence()
    private let key = "scheduledNotifications"
    
    func save(_ notif: Notification) {
        var list = loadAll()
        list.append(notif)
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadAll() -> [Notification] {
        guard
            let data = UserDefaults.standard.data (forKey: key) ,
            let arr = try? JSONDecoder () .decode([Notification].self, from: data)
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

