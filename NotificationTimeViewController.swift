import UIKit

class NotificationTimeViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scheduleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // iOS 14 以降なら preferredDatePickerStyle を設定すると◎
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        // 最小日時を現在日時に制限
        datePicker.minimumDate = Date()
    }

    @IBAction func scheduleTapped(_ sender: UIButton) {
        let selectedDate = datePicker.date

        // 通知許可がまだならリクエスト
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    guard granted else { return }
                    DispatchQueue.main.async {
                        NotificationManager.shared.scheduleNotification(
                            at: selectedDate,
                            title: "予約通知",
                            body: "設定した時間になりました！"
                        )
                        self.showConfirmation()
                    }
                }
            case .authorized, .provisional:
                // メインスレッドでスケジュール
                DispatchQueue.main.async {
                    NotificationManager.shared.scheduleNotification(
                        at: selectedDate,
                        title: "予約通知",
                        body: "設定した時間になりました！"
                    )
                    self.showConfirmation()
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            @unknown default:
                break
            }
        }
    }

    // 確認ダイアログ
    private func showConfirmation() {
        let alert = UIAlertController(
            title: "完了",
            message: "通知を設定しました。\n\(formatted(date: datePicker.date))",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // 許可されていないときの案内
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "通知が許可されていません",
            message: "設定アプリから通知を有効にしてください。",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "設定を開く", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        alert.addAction(.init(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    // 日付フォーマット
    private func formatted(date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}

