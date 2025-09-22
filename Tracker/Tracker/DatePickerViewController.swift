

import UIKit

final class DatePickerViewController: UIViewController {

    // входные/выходные параметры
    var initialDate: Date = Date()
    var onPick: ((Date) -> Void)?

    private let picker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.isUserInteractionEnabled = true

        // Календарь в виде инлайн-таблицы
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar = Calendar(identifier: .gregorian)
        picker.timeZone = .current
        picker.date = initialDate

        // реагируем на тыки по дням
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        // Лейаут
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        navigationItem.title = "Выберите дату"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        // сразу прокидываем выбранную дату наружу
        onPick?(sender.date)
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}
