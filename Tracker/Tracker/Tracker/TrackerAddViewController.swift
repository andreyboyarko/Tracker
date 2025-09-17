
import UIKit

final class TrackerAddViewController: UIViewController {

    // MARK: - UI
    private let createTrackerButton = TrackerButton(title: "Привычка")
    private let createIrregularButton = TrackerButton(title: "Нерегулярное событие")
    private let stackView = UIStackView()

    // MARK: - Callbacks
    var onTrackerAdded: ((TrackerCategory) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "background") ?? .systemBackground
        navigationItem.title = "Создание трекера"
        applyNavBarStyle(prefersLargeTitle: false)   // единый стиль заголовка

        setupStack()
        setupButtons()
        layout()
    }

    // MARK: - Setup
    private func setupStack() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    }

    private func setupButtons() {
        createTrackerButton.addTarget(self, action: #selector(createTrackerTapped), for: .touchUpInside)
        createIrregularButton.addTarget(self, action: #selector(createIrregularTapped), for: .touchUpInside)

        stackView.addArrangedSubview(createTrackerButton)
        stackView.addArrangedSubview(createIrregularButton)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Actions
    @objc private func createTrackerTapped() {
        pushCreateTracker(isIrregular: false)
    }

    @objc private func createIrregularTapped() {
        pushCreateTracker(isIrregular: true)
    }

    private func pushCreateTracker(isIrregular: Bool) {
        let vc = NewTrackerCellViewController()
        vc.onTrackerAdded = { [weak self] tracker in
            self?.onTrackerAdded?(tracker)
            self?.dismiss(animated: true)
        }
        vc.showSchedule = !isIrregular
        vc.modalPresentationStyle = .pageSheet

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
