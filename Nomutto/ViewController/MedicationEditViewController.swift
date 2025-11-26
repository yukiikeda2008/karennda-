//
//  MedicationEditViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import UIKit

final class MedicationEditViewController: UIViewController {
    // MARK: - UI
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let nameField = UITextField()
    private let dosesPerDayField = UITextField()     // 1日の服用回数（整数）
    private let dosePerIntakeField = UITextField()  // 1回の服用量（小数OK）
    private let noteField = UITextField()

    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()

    private let schedulesHeader = UILabel()
    private let schedulesTable = UITableView(frame: .zero, style: .insetGrouped)
    private let addScheduleButton = UIButton(type: .system)

    private let saveButton = UIButton(type: .system)

    // MARK: - State
    private var schedules: [DoseSchedule] = []
    private var editingMedication: Medication?

    // MARK: - Init
    init(editing medication: Medication? = nil) {
        self.editingMedication = medication
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        // TabBar/Storyboard 経由の生成に対応
        self.editingMedication = nil
        super.init(coder: aDecoder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = editingMedication == nil ? "薬を登録" : "薬を編集"
        view.backgroundColor = .systemBackground

        setupLayout()
        setupFields()
        setupTable()
        setupActions()
        if let med = editingMedication { apply(medication: med) }
    }

    // MARK: - Setup
    private func setupLayout() {
        scroll.keyboardDismissMode = .interactive
        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        scroll.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])

        // Fields
        stack.addArrangedSubview(labeledField("薬の名前", nameField))
        stack.addArrangedSubview(twoColumns(
            labeledField("1日の服用回数", dosesPerDayField),
            labeledField("1回の服用量", dosePerIntakeField)
        ))
        stack.addArrangedSubview(labeledField("メモ (任意)", noteField))

        // Dates
        let startBox = labeledBox(title: "開始日", view: startDatePicker)
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.timeZone = .current
        let endBox = labeledBox(title: "終了日 (任意)", view: endDatePicker)
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.timeZone = .current
        stack.addArrangedSubview(startBox)
        stack.addArrangedSubview(endBox)

        // Schedules header + table + add button
        schedulesHeader.text = "スケジュール (時刻・曜日・1回量)"
        schedulesHeader.font = .preferredFont(forTextStyle: .headline)
        stack.addArrangedSubview(schedulesHeader)

        schedulesTable.heightAnchor.constraint(equalToConstant: 240).isActive = true
        stack.addArrangedSubview(schedulesTable)

        addScheduleButton.setTitle("＋ スケジュールを追加", for: .normal)
        addScheduleButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        addScheduleButton.tintColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
        stack.addArrangedSubview(addScheduleButton)

        // Save
        saveButton.setTitle("保存する", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        stack.addArrangedSubview(saveButton)
    }

    private func setupFields() {
        [nameField, dosesPerDayField, dosePerIntakeField, noteField].forEach {
            $0.borderStyle = .roundedRect
            $0.clearButtonMode = .whileEditing
        }
        dosesPerDayField.keyboardType = .numberPad
        dosePerIntakeField.keyboardType = .decimalPad
    }

    private func setupTable() {
        schedulesTable.register(ScheduleCell.self, forCellReuseIdentifier: "cell")
        schedulesTable.dataSource = self
        schedulesTable.delegate = self
    }

    private func setupActions() {
        addScheduleButton.addTarget(self, action: #selector(addScheduleTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func apply(medication: Medication) {
        nameField.text = medication.name
        dosesPerDayField.text = String(medication.dosesPerDay)
        dosePerIntakeField.text = String(medication.dosePerIntake)
        noteField.text = medication.note
        startDatePicker.date = medication.startDate
        if let end = medication.endDate { endDatePicker.date = end }
        schedules = medication.schedules
        schedulesTable.reloadData()
    }

    // MARK: - Actions
    @objc private func addScheduleTapped() {
        let editor = ScheduleEditorViewController()
        editor.onSave = { [weak self] schedule in
            guard let self else { return }
            self.schedules.append(schedule)
            self.schedulesTable.reloadData()
        }
        present(UINavigationController(rootViewController: editor), animated: true)
    }

    @objc private func saveTapped() {
        // 入力チェック（最小限）
        guard let name = nameField.text, !name.isEmpty else { toast("薬の名前を入力してください") ; return }
        let dosesPerDay = Int(dosesPerDayField.text ?? "") ?? 0
        guard dosesPerDay > 0 else { toast("1日の服用回数を入力してください") ; return }
        let dosePerIntake = Double(dosePerIntakeField.text ?? "") ?? 0
        guard dosePerIntake > 0 else { toast("1回の服用量を入力してください") ; return }
        let note = (noteField.text ?? "").isEmpty ? nil : noteField.text

        let start = startDatePicker.date
        let end: Date? = endDatePicker.date >= startDatePicker.date ? endDatePicker.date : nil

        var med = editingMedication ?? Medication(
            name: name,
            note: note,
            startDate: start,
            endDate: end,
            dosesPerDay: dosesPerDay,
            dosePerIntake: dosePerIntake,
            schedules: []
        )

        // schedules の medicationID をこの med.id に差し替える
        let fixed = schedules.map { s -> DoseSchedule in
            var t = s
            t.medicationID = med.id
            return t
        }
        med.schedules = fixed

        // 既存編集のときは上書き
        med.name = name
        med.note = note
        med.startDate = start
        med.endDate = end
        med.dosesPerDay = dosesPerDay
        med.dosePerIntake = dosePerIntake

        MedicationStore.upsert(med)
        NotificationManager.shared.cancelWeekly(for: med)
        NotificationManager.shared.scheduleWeekly(for: med)
        dismissOrPop()
    }

    private func dismissOrPop() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func toast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak alert] in alert?.dismiss(animated: true) }
    }

    // MARK: - Small UI helpers
    private func labeledField(_ title: String, _ field: UITextField) -> UIStackView {
        let label = UILabel(); label.text = title; label.font = .preferredFont(forTextStyle: .subheadline)
        let v = UIStackView(arrangedSubviews: [label, field])
        v.axis = .vertical; v.spacing = 6
        return v
    }

    private func labeledBox(title: String, view: UIView) -> UIStackView {
        let label = UILabel(); label.text = title; label.font = .preferredFont(forTextStyle: .subheadline)
        let container = UIView()
        container.layer.cornerRadius = 8
        container.backgroundColor = .secondarySystemGroupedBackground
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        let v = UIStackView(arrangedSubviews: [label, container])
        v.axis = .vertical; v.spacing = 6
        return v
    }

    private func twoColumns(_ left: UIView, _ right: UIView) -> UIStackView {
        let h = UIStackView(arrangedSubviews: [left, right])
        h.axis = .horizontal; h.spacing = 12; h.distribution = .fillEqually
        return h
    }
}

// MARK: - Table
extension MedicationEditViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { schedules.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScheduleCell
        cell.configure(with: schedules[indexPath.row])
        cell.onDelete = { [weak self] in
            self?.schedules.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            schedules.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Schedule Cell
final class ScheduleCell: UITableViewCell {
    private let timeLabel = UILabel()
    private let daysLabel = UILabel()
    private let qtyLabel = UILabel()
    private let deleteBtn = UIButton(type: .close)

    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let h1 = UIStackView(arrangedSubviews: [timeLabel, UIView(), deleteBtn])
        h1.axis = .horizontal
        let h2 = UIStackView(arrangedSubviews: [daysLabel, UIView(), qtyLabel])
        h2.axis = .horizontal
        let v = UIStackView(arrangedSubviews: [h1, h2])
        v.axis = .vertical; v.spacing = 4
        contentView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        deleteBtn.addTarget(self, action: #selector(deleteTap), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with s: DoseSchedule) {
        timeLabel.text = String(format: "%02d:%02d", s.hour, s.minute)
        let mapping = [1:"日",2:"月",3:"火",4:"水",5:"木",6:"金",7:"土"]
        let days = s.daysOfWeek.sorted().compactMap { mapping[$0] }.joined(separator: " ")
        daysLabel.text = days.isEmpty ? "曜日なし" : days
        qtyLabel.text = "量: \(s.quantity)"
    }

    @objc private func deleteTap() { onDelete?() }
}

// MARK: - Schedule Editor
final class ScheduleEditorViewController: UIViewController {
    var onSave: ((DoseSchedule) -> Void)?

    private let timePicker = UIDatePicker()
    private let qtyField = UITextField()
    private let daysButtons: [UIButton] = (1...7).map { i in
        let b = UIButton(type: .system)
        let symbols = ["日","月","火","水","木","金","土"]
        b.setTitle(symbols[i-1], for: .normal)
        b.tag = i
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        return b
    }

    private var selectedDays = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "スケジュール追加"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = .init(title: "追加", style: .done, target: self, action: #selector(save))

        let stack = UIStackView(); stack.axis = .vertical; stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 24, right: 16)
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        // 時刻
        let timeLabel = UILabel(); timeLabel.text = "時刻"; timeLabel.font = .preferredFont(forTextStyle: .subheadline)
        timePicker.datePickerMode = .time; timePicker.preferredDatePickerStyle = .wheels
        let timeBox = UIView(); timeBox.layer.cornerRadius = 8; timeBox.backgroundColor = .secondarySystemGroupedBackground
        timeBox.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: timeBox.topAnchor, constant: 6),
            timePicker.leadingAnchor.constraint(equalTo: timeBox.leadingAnchor, constant: 12),
            timePicker.trailingAnchor.constraint(equalTo: timeBox.trailingAnchor, constant: -12),
            timePicker.bottomAnchor.constraint(equalTo: timeBox.bottomAnchor, constant: -6)
        ])
        stack.addArrangedSubview(timeLabel)
        stack.addArrangedSubview(timeBox)

        // 量
        let qtyLabel = UILabel(); qtyLabel.text = "1回量"; qtyLabel.font = .preferredFont(forTextStyle: .subheadline)
        qtyField.borderStyle = .roundedRect; qtyField.keyboardType = .decimalPad
        stack.addArrangedSubview(qtyLabel)
        stack.addArrangedSubview(qtyField)

        // 曜日
        let daysLabel = UILabel(); daysLabel.text = "曜日"; daysLabel.font = .preferredFont(forTextStyle: .subheadline)
        let grid = UIStackView(); grid.axis = .horizontal; grid.spacing = 8; grid.distribution = .fillEqually
        daysButtons.forEach { b in
            b.addTarget(self, action: #selector(toggleDay(_:)), for: .touchUpInside)
            grid.addArrangedSubview(b)
        }
        stack.addArrangedSubview(daysLabel)
        stack.addArrangedSubview(grid)
    }

    @objc private func toggleDay(_ sender: UIButton) {
        if selectedDays.contains(sender.tag) {
            selectedDays.remove(sender.tag)
            sender.backgroundColor = .clear
        } else {
            selectedDays.insert(sender.tag)
            sender.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        }
    }

    @objc private func save() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        let hour = comps.hour ?? 8
        let minute = comps.minute ?? 0
        let qty = Double(qtyField.text ?? "") ?? 1
        // medicationID は親で確定させるので、ここではダミー
        var schedule = DoseSchedule(medicationID: UUID(), hour: hour, minute: minute, daysOfWeek: selectedDays, quantity: qty)
        onSave?(schedule)
        dismiss(animated: true)
    }

    @objc private func close() { dismiss(animated: true) }
}
