//
//  CalendarViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/09.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet var calendarView: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate = self
        calendarView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
        fileprivate lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        // 祝日判定を行い結果を返すメソッド(True:祝日)
        func judgeHoliday(_ date : Date) -> Bool {
            //祝日判定用のカレンダークラスのインスタンス
            let tmpCalendar = Calendar(identifier: .gregorian)

            // 祝日判定を行う日にちの年、月、日を取得
            let year = tmpCalendar.component(.year, from: date)
            let month = tmpCalendar.component(.month, from: date)
            let day = tmpCalendar.component(.day, from: date)
            
            // CalculateCalendarLogic()：祝日判定のインスタンスの生成
            let holiday = CalculateCalendarLogic()
            
            return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        }
        // date型 -> 年月日をIntで取得
        func getDay(_ date:Date) -> (Int,Int,Int){
            let tmpCalendar = Calendar(identifier: .gregorian)
            let year = tmpCalendar.component(.year, from: date)
            let month = tmpCalendar.component(.month, from: date)
            let day = tmpCalendar.component(.day, from: date)
            return (year,month,day)
        }
        
        //曜日判定(日曜日:1 〜 土曜日:7)
        func getWeekIdx(_ date: Date) -> Int{
            let tmpCalendar = Calendar(identifier: .gregorian)
            return tmpCalendar.component(.weekday, from: date)
        }
        
        // 土日や祝日の日の文字色を変える
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            //祝日判定をする（祝日は赤色で表示する）
            if self.judgeHoliday(date){
                return UIColor.red
            }
            
            //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
            let weekday = self.getWeekIdx(date)
            if weekday == 1 {   //日曜日
                return UIColor.red
            }
            else if weekday == 7 {  //土曜日
                return UIColor.blue
            }
            
            return nil
            
        }
    
    // すでにあるクラス内に追加（FSCalendarDelegateメソッド）
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let medicationVC = storyboard.instantiateViewController(withIdentifier: "MedicationInputViewController") as? MedicationInputViewController {
            medicationVC.selectedDate = date
            medicationVC.modalPresentationStyle = .fullScreen // または .pageSheet, .formSheet などでもOK
            self.present(medicationVC, animated: true, completion: nil)
        }
    }
}
