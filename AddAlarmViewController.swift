//
//  AddAlarmViewController.swift AddAlarmViewController.swift AddAlarmViewController.swift AddAlarmViewController.swift AddAlarmViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/09.
//

import UIKit

class AddAlarmViewController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var labelTextField: UITextField!

    @IBAction func saveTapped(_ sender: UIButton) {
        let time = timePicker.date
        let label = labelTextField.text ?? ""
        AlarmManager.shared.addAlarm(time: time, label: label)
        navigationController?.popViewController(animated: true)
    }
}

        // Do any additional setup after loading the view.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


