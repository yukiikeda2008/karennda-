//
//  AlarmListViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/09.
//

// AlarmListViewController.swift

import UIKit

class AlarmListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "アラーム"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    @objc func addTapped() {
        performSegue(withIdentifier: "toAddAlarm", sender: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmManager.shared.alarms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        let alarm = AlarmManager.shared.alarms[indexPath.row]

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        cell.textLabel?.text = formatter.string(from: alarm.time)

        let toggle = UISwitch()
        toggle.isOn = alarm.isOn
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle

        return cell
    }

    @objc func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        let alarm = AlarmManager.shared.alarms[index]
        AlarmManager.shared.toggleAlarm(alarm, isOn: sender.isOn)
    }
}
