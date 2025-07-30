

import UIKit

class MedicationInputViewController: UIViewController {

    var selectedDate: Date!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var noonSwitch: UISwitch!
    @IBOutlet weak var nightSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        dateLabel.text = formatter.string(from: selectedDate)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let morningTaken = morningSwitch.isOn
        let noonTaken = noonSwitch.isOn
        let nightTaken = nightSwitch.isOn

        print("朝: \(morningTaken), 昼: \(noonTaken), 夜: \(nightTaken)")

        self.navigationController?.popViewController(animated: true)
    }
}

