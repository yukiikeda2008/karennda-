import UIKit
import FSCalendar
import CalculateCalendarLogic

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet var calendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
            
        calendarView.delegate = self
        calendarView.dataSource = self
        configureCalendarUI()
        title = "カレンダー"
    }

    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - 祝日判定
    func judgeHoliday(_ date : Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // MARK: - 曜日や祝日による色分け
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if self.judgeHoliday(date) { return .red }
        let weekday = self.getWeekIdx(date)
        if weekday == 1 { return .red }      // 日曜日
        else if weekday == 7 { return .blue } // 土曜日
        return nil
    }
    
    // MARK: - カレンダーUI設定
    private func configureCalendarUI() {
        // 日本語ロケール設定
        calendarView.locale = Locale(identifier: "ja_JP")
        calendarView.scope = .month
        calendarView.scrollDirection = .horizontal
        calendarView.placeholderType = .fillHeadTail
        
        // --- ヘッダー背景色 ---
        DispatchQueue.main.async {
            let header = self.calendarView.calendarHeaderView
            let headerBackground = UIView(frame: header.bounds)
            headerBackground.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
            headerBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            header.insertSubview(headerBackground, at: 0)
        }

        // 曜日行の背景色
        calendarView.calendarWeekdayView.backgroundColor = UIColor(red: 177/255, green: 198/255, blue: 177/255, alpha: 1.0)
        
        // ヘッダー設定
        calendarView.appearance.headerDateFormat = "yyyy年M月"
        calendarView.appearance.headerTitleAlignment = .center
        calendarView.appearance.headerTitleFont = .systemFont(ofSize: 20)
        calendarView.appearance.headerTitleColor = .white
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0

        // 曜日ラベル
        let symbols = ["日","月","火","水","木","金","土"]
        for (i, label) in calendarView.calendarWeekdayView.weekdayLabels.enumerated() {
            label.text = symbols[i % symbols.count]
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            if i == 0 { label.textColor = .systemRed }
            else if i == 6 { label.textColor = .systemBlue }
            else { label.textColor = .secondaryLabel }
        }

        // 日付フォント・色
        calendarView.appearance.titleFont = .systemFont(ofSize: 16, weight: .regular)
        calendarView.appearance.titleDefaultColor = .label

        // 今日の日付の見た目
        calendarView.appearance.todayColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
        calendarView.appearance.titleTodayColor = .white
        calendarView.appearance.todaySelectionColor = UIColor(red: 177/255, green: 198/255, blue: 177/255, alpha: 1.0)
        calendarView.appearance.selectionColor = UIColor(red: 177/255, green: 198/255, blue: 177/255, alpha: 1.0)
        calendarView.appearance.titleSelectionColor = .white
        calendarView.appearance.weekdayTextColor = .secondaryLabel
        calendarView.appearance.borderRadius = 0.0 // ✅角丸なし

        // 背景を統一
        calendarView.backgroundColor = .white
        calendarView.clipsToBounds = true

        // ✅ 格子の余白を完全になくす設定
        if let layout = calendarView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0 // 列間をゼロ
            layout.minimumLineSpacing = 0      // 行間をゼロ
        }
    }
    
    // MARK: - 日付選択時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let vc = IntakeLogViewController(selectedDate: date)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

