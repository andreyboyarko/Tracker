

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
        applyNavBarStyle(prefersLargeTitle: false) // единый стиль заголовка

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

        // Оборачиваем в навигацию и делаем непрозрачный бар (как в макете)
        let nav = UINavigationController(rootViewController: vc)
        configurePresentedNavBarAppearance(for: nav)

        // Компактный лист
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        present(nav, animated: true)
    }

    /// Непрозрачный навбар для презентуемого контроллера (чтобы фон не «просвечивал»)
    private func configurePresentedNavBarAppearance(for nav: UINavigationController) {
        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = UIColor(named: "background") ?? .systemBackground
        ap.shadowColor = .clear

        // Цвет/шрифт заголовка можно оставить системными или подставить свои
        ap.titleTextAttributes = [
            .foregroundColor: UIColor(named: "color") ?? .label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        nav.navigationBar.standardAppearance = ap
        nav.navigationBar.scrollEdgeAppearance = ap
        nav.navigationBar.compactAppearance = ap
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.tintColor = UIColor(named: "color") ?? .label
    }
}
