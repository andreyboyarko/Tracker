import UIKit

final class TrackerAddViewController: UIViewController {
    // MARK: - UI
    private let createTrackerButton = TrackerButton(title: L10n.habit)
    private let createIrregularButton = TrackerButton(title: L10n.irregularHabit)
    private let stackView = UIStackView()

    // MARK: - Callbacks
    var onTrackerAdded: ((TrackerCategory) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = L10n.createTracker
        setupUI()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupUI() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        createTrackerButton.addTarget(self, action: #selector(createTrackerTapped), for: .touchUpInside)
        createIrregularButton.addTarget(self, action: #selector(createIrregularTapped), for: .touchUpInside)

        // (optional) идентификаторы для UI-тестов
        createTrackerButton.accessibilityIdentifier = "add_habit_button"
        createIrregularButton.accessibilityIdentifier = "add_irregular_button"

        stackView.addArrangedSubview(createTrackerButton)
        stackView.addArrangedSubview(createIrregularButton)
        view.addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func createTrackerTapped() {
        pushCreateTracker(isIrregular: false)
    }

    @objc private func createIrregularTapped() {
        pushCreateTracker(isIrregular: true)
    }

    // MARK: - Navigation
    private func pushCreateTracker(isIrregular: Bool) {
        let vc = NewTrackerCellViewController()
        vc.onTrackerAdded = { [weak self] tracker in
            self?.onTrackerAdded?(tracker)
            self?.dismiss(animated: true)
        }
        vc.showSchedule = !isIrregular

        vc.modalPresentationStyle = .pageSheet
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}
