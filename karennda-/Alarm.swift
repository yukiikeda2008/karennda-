//
//  Alarm.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/09.
//

import Foundation

struct Alarm: Codable {
    var id: String
    var time: Date
    var label: String
    var isOn: Bool
}
