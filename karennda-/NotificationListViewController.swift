//
//  NotificationListViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/07/23.
//

import UIKit

class NotificationListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var notifications: [Notification] = []
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // 毎回最新を読み込み
            notifications = Persistence.shared.loadAll()
            tableView.reloadData()
        }

}



extension NotificationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(notifications.count)
        return notifications.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let notif = notifications[indexPath.row]
        
        //タイトルをメインテキスト、日時をサブテキストに表示
        cell.textLabel?.text = dateFormatter.string(from: notif.date)
        return cell
    }
}

extension NotificationListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {
        
        if editingStyle == .delete{
            let id = notifications[indexPath.row].id
            
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [id])
            
            //永続化から削除
            Persistence.shared.delete(id: id)
            
            //配列にも反映してテーブル更新
            notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic )
        }
        
    }
}
