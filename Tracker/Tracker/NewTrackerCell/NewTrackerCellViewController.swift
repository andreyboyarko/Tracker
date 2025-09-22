

import UIKit

final class NewTrackerCellViewController: UIViewController {
    private let containerView = UIView()
    private let titleTextField = UITextField()
    private let clearButton = UIButton()
    private let errorLabel = UILabel()
    
    private let cancelButton = UIButton()
    private let saveButton = TrackerButton(title: "Сохранить")
    private let buttonStackView = UIStackView()
    
    private let buttonsTableView = UITableView(frame: .zero, style: .plain)
    private let buttonTitles = ["Категория", "Расписание"]
    
    private var trackerCategory: TrackerCategory?
    private var trackerWeekdays: [WeekdaysEnum] = []
    var onTrackerAdded: ((TrackerCategory) -> Void)?
    var showSchedule = false
    
    private var showErrorLabel = false {
        didSet { errorLabel.isHidden = !showErrorLabel }
    }
    
    private var showClearButton = false {
        didSet {
            clearButton.isHidden = !showClearButton
            saveButton.isEnabled = showClearButton
            saveButton.backgroundColor = showClearButton ? .color : .ybGray
        }
    }
    
    private let maxLength = 38
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = "Новая привычка"
        
        setupViews()
        setupLayout()
    }
    
    private func setupViews() {
        // контейнер для TextField
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // текстовое поле
        titleTextField.placeholder = "Введите название трекера"
        titleTextField.addTarget(self, action: #selector(limitLength), for: .editingChanged)
        titleTextField.textColor = .color
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // кнопка очистки
        clearButton.setImage(UIImage(resource: .clear), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        // ошибка
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.textColor = .ybRed
        errorLabel.font = .ypRegular
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // таблица кнопок
        buttonsTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsTableView.backgroundColor = .background
        buttonsTableView.separatorStyle = .singleLine
        buttonsTableView.layer.cornerRadius = 16
        buttonsTableView.layer.masksToBounds = true
        buttonsTableView.isScrollEnabled = false
        buttonsTableView.delegate = self
        buttonsTableView.dataSource = self
        buttonsTableView.register(NewTrackerCell.self, forCellReuseIdentifier: NewTrackerCell.identifier)
        
        // нижние кнопки
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor.ybRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .ypRegular
        cancelButton.setTitleColor(.ybRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        showClearButton = false
        
        buttonStackView.spacing = 8
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(saveButton)
        
        containerView.addSubview(titleTextField)
        containerView.addSubview(clearButton)
        
        view.addSubview(containerView)
        view.addSubview(errorLabel)
        view.addSubview(buttonsTableView)
        view.addSubview(buttonStackView)
    }
    
    // MARK: setupLayout
    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),
            
            titleTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -41),
            
            clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            
            buttonsTableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: showSchedule ? 150 : 75),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func limitLength(_ textField: UITextField) {
        if let text = textField.text {
            showClearButton = text.count > 0
            showErrorLabel = text.count > maxLength
            
            if showErrorLabel {
                textField.text = String(text.prefix(maxLength))
            }
        }
    }
    
    @objc private func clearTextField() {
        titleTextField.text = ""
        showErrorLabel = false
        showClearButton = false
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        if trackerWeekdays.isEmpty && showSchedule {
            showAlertError(message: "Нужно выбрать хотя бы один день недели")
            return
        }
        
        guard let title = titleTextField.text else {
            showAlertError(message: "Заполните название")
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .ybColor10,
            emoji: "",
            weekdays: showSchedule ? trackerWeekdays : Array(WeekdaysEnum.allCases)
        )
        
        let category = TrackerCategory(title: "Домашний уют", trackers: [tracker])
        onTrackerAdded?(category)
        
        dismiss(animated: true)
    }
    
    @objc private func pushSchedule() {
        let vc = NewTrackerCellScheduleViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.weekdays = trackerWeekdays
        vc.setWeekdays = { [weak self] weekdays in
            self?.trackerWeekdays = weekdays
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func showAlertError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Окей", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension NewTrackerCellViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            pushSchedule()
        }
    }
}

extension NewTrackerCellViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showSchedule ? buttonTitles.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewTrackerCell.identifier,
            for: indexPath
        ) as? NewTrackerCell else {
            return UITableViewCell()
        }
        
        cell.setTitle(buttonTitles[showSchedule ? indexPath.row : 0])
        return cell
    }
}
