//
//  ViewController.swift
//  calendar
//
//  Created by Honoka Nishiyama on 2025/02/19.
//

import UIKit

extension UIColor {
    static var lightBlue: UIColor {
        return UIColor(red: 92.0 / 255, green: 192.0 / 255, blue: 210.0 / 255, alpha: 1.0)
    }
    
    static var lightRed: UIColor {
        return UIColor(red: 195.0 / 255, green: 123.0 / 255, blue: 175.0 / 255, alpha: 1.0)
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let dateManager = DateManager()
    let daysPerWeek: Int = 7
    let cellMargin: CGFloat = 2.0
    var selectedDate = Date()
    var today: Date!
    let weekArray = ["日", "月", "火", "水", "木", "金", "土"]
    var medicationDays: Set<String> = ["2025-02-01", "2025-02-05", "2025-02-10"] // 薬を飲んだ日

    @IBOutlet weak var headerPrevBtn: UIButton!
    @IBOutlet weak var headerNextBtn: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var calenderHeaderView: UIView!
    @IBOutlet weak var calenderCollectionView: UICollectionView!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var CellLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CellLayout.itemSize = CGSize(width: 300, height:105)
    
        if calenderCollectionView == nil {
                print("calenderCollectionView is nil")
            } else {
                print("calenderCollectionView is not nil")
            }

        
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        
        // CalendarCell を登録（修正点）
        calenderCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")

        calenderCollectionView.backgroundColor = UIColor(red:0, green: 200, blue:100, alpha: 0.0)
        headerTitle.text = changeHeaderTitle(date: selectedDate)
        let numberOfItems = dateManager.daysAcquisition()
        dateManager.dateForCellAtIndexPath(numberOfItems)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知許可されました")
            } else {
                print("通知が拒否されました")
            }
        }

    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 7
        } else {
            return dateManager.daysAcquisition()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        cell.backgroundColor = UIColor(red:0, green: 200, blue:100, alpha: 0.0)
        
        if indexPath.row % 7 == 0 {
            cell.textLabel.textColor = UIColor.lightRed
        } else if indexPath.row % 7 == 6 {
            cell.textLabel.textColor = UIColor.lightBlue
        } else {
            cell.textLabel.textColor = UIColor.gray
        }
        
        if indexPath.section == 0 {
            cell.textLabel.text = weekArray[indexPath.row]
        } else {
            cell.textLabel.text = dateManager.conversionDateFormat(indexPath: indexPath)
            // 年月日をフォーマット（"yyyy-MM-dd" 形式に変換）
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let cellDate = formatter.string(from: dateManager.currentMonthOfDates[indexPath.row])
            
            // 服薬した日か確認して背景色を変える or アイコンを追加
            if medicationDays.contains(cellDate) {
                cell.backgroundColor = UIColor.green.withAlphaComponent(0.5) // 服薬日は緑色
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalMargin: CGFloat = cellMargin * CGFloat(daysPerWeek - 1)
        let width: CGFloat = calenderCollectionView.frame.size.width / 9
        let height: CGFloat = width
        return CGSize(width: width, height: 105)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return } // 日付部分のみタップ可能に

        // 選択した日付を取得
        let selectedCellDate = dateManager.currentMonthOfDates[indexPath.row]
        
        // モーダルを作成
        let modalVC = MedicationModalViewController()
        modalVC.selectedDate = selectedCellDate
        
        // 「飲んだ」ボタンが押されたときの処理
        modalVC.onMedicationAdded = { [weak self] date in
            guard let self = self else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)
            
            // 服薬日をセットに追加
            self.medicationDays.insert(dateString)
            
            // カレンダーを再描画
            self.calenderCollectionView.reloadData()
        }

        // モーダルを表示
        modalVC.modalPresentationStyle = .formSheet
        present(modalVC, animated: true, completion: nil)
    }


    func changeHeaderTitle(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }

    @IBAction func tappedHeaderPrevBtn(_ sender: UIButton) {
        selectedDate = dateManager.prevMonth(date: selectedDate)
        calenderCollectionView.reloadData()
        headerTitle.text = changeHeaderTitle(date: selectedDate)
    }

    @IBAction func tappedHeaderNextBtn(_ sender: UIButton) {
        selectedDate = dateManager.nextMonth(date: selectedDate)
        calenderCollectionView.reloadData()
        headerTitle.text = changeHeaderTitle(date: selectedDate)
    }
}

