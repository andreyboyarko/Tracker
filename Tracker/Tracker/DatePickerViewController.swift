

import UIKit

final class DatePickerViewController: UIViewController {

    var initialDate: Date = Date()
    var onPick: ((Date) -> Void)?

    private let picker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline   // «маленький календарь»
        picker.date = initialDate
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Кнопка "Готово" (или можно оставить только тап по календарю)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )
    }

    @objc private func didTapDone() {
        onPick?(picker.date)
        dismiss(animated: true)
    }
}
