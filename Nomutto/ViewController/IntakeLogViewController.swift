//
//  IntakeLogViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import UIKit
import DGCharts

// 依存: Medication / DoseSchedule / IntakeLog と各 Store（MedicationStore / IntakeLogStore）
final class IntakeLogViewController: UIViewController {
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let saveButton = UIButton(type: .system)
    private let pieChart = PieChartView()
    private let chartContainer = UIView()
    
    // MARK: - State
    let selectedDate: Date
    private var sections: [(time: String, rows: [Row])] = []
    
    struct Row {
        let medication: Medication
        let schedule: DoseSchedule
        var checked: Bool
    }
    
    // MARK: - Init
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 日付を日本語表示・背景色付きラベルに
          let df = DateFormatter()
          df.locale = Locale(identifier: "ja_JP")
          df.dateStyle = .medium
          df.timeStyle = .none

          let label = UILabel()
          label.text = df.string(from: selectedDate)
          label.textAlignment = .center
          label.backgroundColor = UIColor(hex: "#849384")
          label.textColor = .white
          label.layer.cornerRadius = 8
          label.layer.masksToBounds = true
          label.font = .boldSystemFont(ofSize: 17)
          label.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
          label.heightAnchor.constraint(equalToConstant: 32).isActive = true
          navigationItem.titleView = label
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // ←ぼかしを消す
            appearance.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0) // 好きな色
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
          
          view.backgroundColor = .systemBackground
          setupUI()
          setupChartAppearance()
          buildSections()
      }
      
      private func setupUI() {
          navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
          
     // 上部: グラフコンテナ
        view.addSubview(chartContainer)
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 中段: テーブル
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 下部: 保存ボタン
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chartContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chartContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            chartContainer.heightAnchor.constraint(equalToConstant: 350),
            
            tableView.topAnchor.constraint(equalTo: chartContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -8),
            
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // グラフをコンテナに配置
        chartContainer.addSubview(pieChart)
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pieChart.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 8),
            pieChart.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: 16),
            pieChart.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor, constant: -16),
            pieChart.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: -8)
        ])
        
        tableView.register(Cell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        saveButton.setTitle("保存する", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func buildSections() {
        let dayKey = selectedDate.dayKey
        let weekday = selectedDate.weekday1to7
        let meds = MedicationStore.load()
        
        var bucket: [String: [Row]] = [:]
        
        for m in meds {
            guard m.startDate <= selectedDate, (m.endDate == nil || selectedDate <= m.endDate!) else { continue }
            for s in m.schedules {
                guard s.daysOfWeek.contains(weekday) else { continue }
                
                let timeText = String(format: "%02d:%02d", s.hour, s.minute)
                
                let saved = IntakeLogStore.fetch(dayKey: dayKey, medicationID: m.id, scheduleID: s.id)
                let checked = saved?.taken ?? false
                
                bucket[timeText, default: []].append(Row(medication: m, schedule: s, checked: checked))
            }
        }
        
        sections = bucket
            .map { ($0.key, $0.value.sorted { $0.medication.name < $1.medication.name }) }
            .sorted { $0.0 < $1.0 }
        
        tableView.reloadData()
        updateChartCounts()
    }
    
    @objc private func saveTapped() {
        let dayKey = selectedDate.dayKey
        for (_, rows) in sections {
            for r in rows {
                let log = IntakeLog(
                    id: UUID(),
                    medicationID: r.medication.id,
                    scheduleID: r.schedule.id,
                    dayKey: dayKey,
                    taken: r.checked,
                    takenAt: r.checked ? Date() : nil
                )
                IntakeLogStore.upsert(log)
            }
        }
        dismiss(animated: true)
    }
    
    @objc private func close() { dismiss(animated: true) }
}

// MARK: - Table
extension IntakeLogViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section].time }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        cell.configure(name: row.medication.name, quantity: row.schedule.quantity, checked: row.checked)
        cell.onToggle = { [weak self, weak tableView] isOn in
            guard let self = self else { return }
            self.sections[indexPath.section].rows[indexPath.row].checked = isOn
            self.updateChartCounts()
            if let cell = tableView?.cellForRow(at: indexPath) as? Cell {
                cell.setChecked(isOn)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].rows[indexPath.row].checked.toggle()
        if let cell = tableView.cellForRow(at: indexPath) as? Cell {
            cell.setChecked(sections[indexPath.section].rows[indexPath.row].checked)
        }
        updateChartCounts()
    }

    private func setupChartAppearance() {
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        pieChart.rotationEnabled = false
        pieChart.holeRadiusPercent = 0.8
        pieChart.transparentCircleRadiusPercent = 0.83
        pieChart.usePercentValuesEnabled = true
        pieChart.centerAttributedText = NSAttributedString(string: "0%\n0/0",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 20),
                         .foregroundColor: UIColor.label])
    }

    private func updateChartCounts() {
        let total = sections.reduce(0) { $0 + $1.rows.count }
        let taken = sections.reduce(0) { $0 + $1.rows.filter { $0.checked }.count }

        let entries = [
            PieChartDataEntry(value: total == 0 ? 0 : Double(taken), label: "Taken"),
            PieChartDataEntry(value: total == 0 ? 0 : Double(total - taken), label: "Remaining")
        ]
        let set = PieChartDataSet(entries: entries, label: "")
        set.colors = [UIColor(hex: "#849384"), UIColor.systemGray4] // ← 色変更
        set.drawValuesEnabled = false

        pieChart.data = PieChartData(dataSet: set)

        let percent = total > 0 ? Int((Double(taken)/Double(total))*100.0 + 0.5) : 0
        let center = NSMutableAttributedString()
        center.append(NSAttributedString(string: "\(percent)%\n",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 28), .foregroundColor: UIColor.label]))
        center.append(NSAttributedString(string: "\(taken)/\(total)",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.secondaryLabel]))
        pieChart.centerAttributedText = center

        pieChart.animate(xAxisDuration: 0.15, yAxisDuration: 0.15)
    }

    private func updateChartByQuantity() {
        let totals = sections.flatMap { $0.rows }
        let totalQty = totals.reduce(0.0) { $0 + $1.schedule.quantity }
        let takenQty = totals.filter { $0.checked }.reduce(0.0) { $0 + $1.schedule.quantity }

        let entries = [
            PieChartDataEntry(value: totalQty == 0 ? 0 : takenQty, label: "Taken"),
            PieChartDataEntry(value: totalQty == 0 ? 0 : (totalQty - takenQty), label: "Remaining")
        ]
        let set = PieChartDataSet(entries: entries, label: "")
        set.colors = [UIColor(hex: "#849384"), UIColor.systemGray4] // ← 色変更
        set.drawValuesEnabled = false

        pieChart.data = PieChartData(dataSet: set)

        let percent = totalQty > 0 ? Int((takenQty/totalQty)*100.0 + 0.5) : 0
        let center = NSMutableAttributedString()
        center.append(NSAttributedString(string: "\(percent)%\n",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 28), .foregroundColor: UIColor.label]))
        center.append(NSAttributedString(string: String(format: "%.1f/%.1f", takenQty, totalQty),
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.secondaryLabel]))
        pieChart.centerAttributedText = center

        pieChart.animate(xAxisDuration: 0.15, yAxisDuration: 0.15)
    }

}

// MARK: - Cell with switch
final class Cell: UITableViewCell {
    private let nameLabel = UILabel()
    private let qtyLabel = UILabel()
    private let sw = UISwitch()
    
    var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let left = UIStackView(arrangedSubviews: [nameLabel, qtyLabel])
        left.axis = .vertical; left.spacing = 2
        contentView.addSubview(left); contentView.addSubview(sw)
        left.translatesAutoresizingMaskIntoConstraints = false
        sw.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            left.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            left.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            left.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            sw.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sw.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sw.leadingAnchor.constraint(greaterThanOrEqualTo: left.trailingAnchor, constant: 8)
        ])
        nameLabel.font = .preferredFont(forTextStyle: .body)
        qtyLabel.font = .preferredFont(forTextStyle: .caption1)
        qtyLabel.textColor = .secondaryLabel
        sw.addTarget(self, action: #selector(changed), for: .valueChanged)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(name: String, quantity: Double, checked: Bool) {
        nameLabel.text = name
        qtyLabel.text  = "予定量: \(quantity)"
        sw.isOn = checked
    }
    func setChecked(_ on: Bool) { sw.isOn = on }
    @objc private func changed() { onToggle?(sw.isOn) }
}

// MARK: - UIColor extension for hex
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

