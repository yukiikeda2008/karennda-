import UIKit

final class CalendarViewController: UIViewController {

    private let customCalendarView = CustomCalendarView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        view.addSubview(customCalendarView)
        customCalendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customCalendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customCalendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        customCalendarView.delegate = self
    }
}

extension CalendarViewController: CustomCalendarViewDelegate {
    func calendarView(_ calendarView: CustomCalendarView, didSelect date: Date) {
        // いま FSCalendar の didSelect でやっている処理をそのまま移植
        let vc = IntakeLogViewController(selectedDate: date)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}
