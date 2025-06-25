//
//  DateManager.swift
//  calendar
//
//  Created by Honoka Nishiyama on 2025/02/19.
//

import UIKit

extension Date {
    func monthAgoDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: -1, to: self)!
    }
    
    func monthLaterDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: self)!
    }
}

class DateManager: NSObject {
    
    var currentMonthOfDates = [Date]() // 表記する月の配列
    var selectedDate = Date()
    let daysPerWeek: Int = 7
    var numberOfItems: Int!

    // 月ごとのセルの数を返すメソッド
    func daysAcquisition() -> Int {
        let calendar = Calendar.current
        let rangeOfWeeks = calendar.range(of: .weekOfMonth, in: .month, for: firstDateOfMonth())!
        let numberOfWeeks = rangeOfWeeks.count // 月が持つ週の数
        numberOfItems = numberOfWeeks * daysPerWeek // 週の数×列の数
        return numberOfItems
    }
    
    // 月の初日を取得
    func firstDateOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.day = 1
        return Calendar.current.date(from: components)!
    }
    
    // 表記する日にちの取得
    func dateForCellAtIndexPath(_ numberOfItems: Int) {
        let calendar = Calendar.current
        let ordinalityOfFirstDay = calendar.ordinality(of: .day, in: .weekOfMonth, for: firstDateOfMonth())!
        currentMonthOfDates.removeAll()
        for i in 0..<numberOfItems {
            var dateComponents = DateComponents()
            dateComponents.day = i - (ordinalityOfFirstDay - 1)
            let date = calendar.date(byAdding: dateComponents, to: firstDateOfMonth())!
            currentMonthOfDates.append(date)
        }
    }
    
    // 表記の変更
    func conversionDateFormat(indexPath: IndexPath) -> String {
        dateForCellAtIndexPath(numberOfItems)
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: currentMonthOfDates[indexPath.row])
    }
    
    //前月の表示
    func prevMonth(date: Date) -> Date {
        currentMonthOfDates = []
        selectedDate = date.monthAgoDate()
        return selectedDate
    }
    //次月の表示
    func nextMonth(date: Date) -> Date {
        currentMonthOfDates = []
        selectedDate = date.monthLaterDate()
        return selectedDate
    }
}
