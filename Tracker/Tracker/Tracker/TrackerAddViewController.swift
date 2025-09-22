

import UIKit

final class TrackerAddViewController: UIViewController {
    private let createTrackerButton = TrackerButton(title: "Привычка")
    private let createIrregularButton = TrackerButton(title: "Нерегулярное событие")
    private let stackView = UIStackView()
    
    var onTrackerAdded: ((TrackerCategory) -> Void)?
    
    override func viewDidLoad() {
        view.backgroundColor = .ybBlack
        navigationItem.title = "Создание трекера"
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        
        createTrackerButton.addTarget(self, action: #selector(createTrackerTapped), for: .touchUpInside)
        createIrregularButton.addTarget(self, action: #selector(createIrregularTapped), for: .touchUpInside)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(createTrackerButton)
        stackView.addArrangedSubview(createIrregularButton)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func createTrackerTapped() {
        pushCreateTracker(isIrregular: false)
    }
    
    @objc private func createIrregularTapped() {
        pushCreateTracker(isIrregular: true)
    }
    
    private func pushCreateTracker(isIrregular: Bool){
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

