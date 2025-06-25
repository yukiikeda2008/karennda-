//
//  MedicationModalViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/03/10.
//

import UIKit

class MedicationModalViewController: UIViewController {
    
    var selectedDate: Date!
    var onMedicationAdded: ((Date) -> Void)?
    
    private let label = UILabel()
    private let takeMedicineBUtton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //日付表示ラベル
        label.textAlignment = .center
        label.text = formattedDate(selectedDate)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 「飲んだ」ボタン
        takeMedicineBUtton.setTitle("飲んだ", for: .normal)
        takeMedicineBUtton.addTarget(self, action: #selector(takeMedicineTapped), for: .touchUpInside)
        view.addSubview(takeMedicineBUtton)
        takeMedicineBUtton.translatesAutoresizingMaskIntoConstraints = false
        
        
        //閉じるボタン
        closeButton.setTitle("閉じる", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Auto Layout
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            takeMedicineBUtton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            takeMedicineBUtton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: takeMedicineBUtton.bottomAnchor, constant: 20) ])
        
    }
    //「飲んだ」ボタンタップ時
    @objc func takeMedicineTapped() {
        onMedicationAdded?(selectedDate) //コールバック日付を返す
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeTapped() {
        dismiss(animated: true, completion: nil)
        
    }
    //日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
        
    }
}
