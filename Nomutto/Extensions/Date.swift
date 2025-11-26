//
//  Date.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import Foundation

extension Date {
    var dayKey: String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
    var weekday1to7: Int { Calendar.current.component(.weekday, from: self) }
}
