//
//  CustomCalendarView.swift
//  karennda-
//
//  Created by Honoka Nishiyama on 2025/12/10.
//

import UIKit
import CalculateCalendarLogic

struct DayItem {
    let date: Date
    let isInCurrentMonth: Bool
}

protocol CustomCalendarViewDelegate: AnyObject {
    func calendarView(_ calendarView: CustomCalendarView, didSelect date: Date)
}

final class CustomCalendarView: UIView {

    weak var delegate: CustomCalendarViewDelegate?
    private var rowCount: Int = 6

    // カレンダー計算用
    private let calendar = Calendar(identifier: .gregorian)
    private var currentMonth: Date = Date()
    private var days: [DayItem] = []

    // UI
    private let headerLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let weekdayStack = UIStackView()
    private let collectionView: UICollectionView

    // 祝日判定（いまのロジックを流用）
    private let holidayLogic = CalculateCalendarLogic()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .systemGray6

        // --- ヘッダー ---
        headerLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textAlignment = .center
        headerLabel.textColor = .white

        prevButton.setTitle("<", for: .normal)
        prevButton.tintColor = .white
        nextButton.setTitle(">", for: .normal)
        nextButton.tintColor = .white
        prevButton.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)

        let headerContainer = UIView()
        headerContainer.addSubview(headerLabel)
        headerContainer.addSubview(prevButton)
        headerContainer.addSubview(nextButton)
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)

        // --- 曜日ラベル ---
        weekdayStack.axis = .horizontal
        weekdayStack.distribution = .fillEqually
        weekdayStack.translatesAutoresizingMaskIntoConstraints = false
        weekdayStack.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)

        let symbols = ["日","月","火","水","木","金","土"]
        for (index, symbol) in symbols.enumerated() {
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            switch index {
            case 0: label.textColor = .systemRed
            case 6: label.textColor = .systemBlue
            default: label.textColor = .secondaryLabel
            }
            weekdayStack.addArrangedSubview(label)
        }

        // --- コレクションビュー ---
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)

        // --- レイアウトをビュー階層に追加 ---
        addSubview(headerContainer)
        addSubview(weekdayStack)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            prevButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            prevButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 8),
            prevButton.widthAnchor.constraint(equalToConstant: 44),

            nextButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -8),
            nextButton.widthAnchor.constraint(equalToConstant: 44),

            headerLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            weekdayStack.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            weekdayStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekdayStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekdayStack.heightAnchor.constraint(equalToConstant: 24),

            collectionView.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 初期状態
        currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        reload()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width / 7.0
            let rows = CGFloat(rowCount)
            let height = collectionView.bounds.height / rows
            layout.itemSize = CGSize(width: floor(width), height: floor(height))
        }
    }

    // MARK: - 月移動
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            changeMonth(by: 1)   // 次の月へ
        case .right:
            changeMonth(by: -1)  // 前の月へ
        default:
            break
        }
    }
    
    @objc private func didTapPrev() {
        changeMonth(by: -1)
    }
    
    @objc private func didTapNext() {
        changeMonth(by: 1)
    }
    
    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newMonth
        
        // アニメーション付きで切り替え（好きに変えてOK）
        UIView.transition(with: collectionView,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.reload()
        },
                          completion: nil)
    }

    // MARK: - データ生成 & 反映
    private func reload() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        headerLabel.text = formatter.string(from: currentMonth)

        days = generateDays(for: currentMonth)
        collectionView.reloadData()

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func generateDays(for month: Date) -> [DayItem] {
        var items: [DayItem] = []

        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return items
        }

        // 1日の曜日（1:日曜〜7:土曜）
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let numberOfDaysInMonth = range.count

        // この月で実際に使うセル数（前月ぶんの空き + 当月日数）
        let usedCellCount = (firstWeekday - 1) + numberOfDaysInMonth

        // 何行必要か（4〜6行）
        let rows = Int(ceil(Double(usedCellCount) / 7.0))
        rowCount = min(max(rows, 4), 6)   // 4〜6 の範囲に収める

        let totalCells = rowCount * 7

        let startOffset = -(firstWeekday - 1)
        for i in 0..<totalCells {
            if let date = calendar.date(byAdding: .day, value: startOffset + i, to: firstOfMonth) {
                let monthOfDate = calendar.component(.month, from: date)
                let currentMonthValue = calendar.component(.month, from: month)
                let isInCurrent = (monthOfDate == currentMonthValue)
                items.append(DayItem(date: date, isInCurrentMonth: isInCurrent))
            }
        }
        return items
    }

    // 祝日判定 & 曜日判定（元コードを流用）
    private func isJapaneseHoliday(_ date: Date) -> Bool {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return holidayLogic.judgeJapaneseHoliday(year: year, month: month, day: day)
    }

    private func weekdayIndex(_ date: Date) -> Int {
        calendar.component(.weekday, from: date) // 1=日, 7=土
    }
}

extension CustomCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DayCell.reuseIdentifier,
            for: indexPath
        ) as? DayCell else {
            return UICollectionViewCell()
        }

        let item = days[indexPath.item]
        let day = calendar.component(.day, from: item.date)
        cell.dayLabel.text = "\(day)"

        // まずは通常の文字色を決める
        let baseTextColor: UIColor
        if isJapaneseHoliday(item.date) {
            baseTextColor = .systemRed
        } else {
            let weekday = weekdayIndex(item.date)
            if weekday == 1 {
                baseTextColor = .systemRed
            } else if weekday == 7 {
                baseTextColor = .systemBlue
            } else {
                baseTextColor = item.isInCurrentMonth ? .label : .tertiaryLabel
            }
        }
        cell.dayLabel.textColor = baseTextColor

        // 今日なら丸印を表示（当月だけを対象にするなら isInCurrentMonth も見る）
        let isToday = calendar.isDateInToday(item.date) && item.isInCurrentMonth
        cell.configureToday(isToday: isToday, baseTextColor: baseTextColor)

        cell.contentView.backgroundColor = .clear
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = days[indexPath.item]
        delegate?.calendarView(self, didSelect: item.date)
    }
}
