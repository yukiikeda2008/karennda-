import UIKit

final class MedicationListViewController: UIViewController {
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "登録されているお薬はありません\n右上の＋から追加してください"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    // MARK: - State
    private var items: [Medication] = [] {
        didSet { emptyLabel.isHidden = !items.isEmpty }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // ←ぼかしを消す
            appearance.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0) // 好きな色
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            
            
        }
        title = "お薬一覧"
        
        view.backgroundColor = .systemBackground
        setupTable()
        setupNavItems()
        layout()
    }

  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    // MARK: - Setup
    private func setupTable() {
        tableView.register(MedCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 64
        tableView.tableFooterView = UIView()
    }

    private func setupNavItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    private func layout() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Actions
    @objc private func addTapped() {
        let editor = MedicationEditViewController()
        navigationController?.pushViewController(editor, animated: true)
    }

    private func reload() {
        items = MedicationStore.load()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension MedicationListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let m = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MedCell
        cell.configure(with: m)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let editor = MedicationEditViewController(editing: items[indexPath.row])
        navigationController?.pushViewController(editor, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let med = items[indexPath.row]
            NotificationManager.shared.cancelWeekly(for: med)  // ← これで曜日付きIDを一括取消
            
            MedicationStore.delete(id: med.id)
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Cell
final class MedCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let v = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        v.axis = .vertical
        v.spacing = 4
        contentView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        titleLabel.font = .preferredFont(forTextStyle: .body)
        subLabel.font = .preferredFont(forTextStyle: .caption1)
        subLabel.textColor = .secondaryLabel
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with m: Medication) {
        titleLabel.text = m.name
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none
        let period: String
        if let end = m.endDate { period = "\(f.string(from: m.startDate)) - \(f.string(from: end))" }
        else { period = "\(f.string(from: m.startDate)) -" }

        let scheduleBadge: String
        if m.schedules.isEmpty {
            scheduleBadge = "スケジュールなし"
        } else {
            // 代表として最初の時刻を表示 + 件数
            let s = m.schedules.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }.first!
            scheduleBadge = String(format: "%02d:%02d を含む %d件", s.hour, s.minute, m.schedules.count)
        }
        subLabel.text = "\(period) / 1日\(m.dosesPerDay)回 × \(m.dosePerIntake) / \(scheduleBadge)"
    }
}
