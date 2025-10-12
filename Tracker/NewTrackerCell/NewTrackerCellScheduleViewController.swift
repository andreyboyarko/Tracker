import UIKit

final class NewTrackerCellScheduleViewController: UIViewController {
    private let tableView = UITableView()
    private let button = TrackerButton(title: "Готово")
    
    private let rowHeight: CGFloat = 75
    private let numberOfRows = CGFloat(WeekdaysEnum.allCases.count)
    
    var weekdays: [WeekdaysEnum] = []
    var setWeekdays: (([WeekdaysEnum]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = "Расписание"
        
        // Таблица
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .background
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewTrackerWeekDayCell.self,
                           forCellReuseIdentifier: NewTrackerWeekDayCell.identifier)
        
        // Кнопка «Готово»
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ybBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
       
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(closePage), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: rowHeight * numberOfRows),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        updateButtonState()
    }
    
    @objc private func closePage() {
        setWeekdays?(weekdays)
        dismiss(animated: true)
    }
    
    private func updateButtonState() {
        let enabled = !weekdays.isEmpty
        button.isEnabled = enabled
        button.backgroundColor = enabled ? .color : .ybGray
    }
}

extension NewTrackerCellScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
}

extension NewTrackerCellScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekdaysEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewTrackerWeekDayCell.identifier,
            for: indexPath
        ) as? NewTrackerWeekDayCell else {
            return UITableViewCell()
        }
        
        let day = WeekdaysEnum.allCases[indexPath.row]
        cell.setWeekday(day)
        cell.isOn = weekdays.contains(day)
        cell.onToggle = { [weak self] day in
            guard let self else { return }
            if let idx = self.weekdays.firstIndex(of: day) {
                self.weekdays.remove(at: idx)
            } else {
                self.weekdays.append(day)
            }
            self.updateButtonState() // <- обновляем состояние кнопки
        }
        return cell
    }
}
