

import UIKit

final class OnboardingViewController: UIViewController {
    private let label = UILabel()
    private let backgroundImageView = UIImageView()
    private let button = TrackerButton(title: "Вот это технологии!")

    init(title: String, image: ImageResource) {
        super.init(nibName: nil, bundle: nil)
        label.text = title
        backgroundImageView.image = UIImage(resource: image)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Текст
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        // Фон
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        // Кнопка
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        // Иерархия
        view.addSubview(backgroundImageView)
        view.addSubview(label)
        view.addSubview(button)
        view.sendSubviewToBack(backgroundImageView)

        // Лейаут
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60),

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24)
        ])
    }

    @objc
    private func didTapButton() {
        UserDefaults.standard.set(true, forKey: Constants.hasSeenOnboardingKey)

        // Берём SceneDelegate, чтобы заменить корень окна
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sd = scene.delegate as? SceneDelegate,
           let window = sd.window {
            let tab = TabBarController(coreDataStack: sd.core)   // ← ВАЖНО: правильный тип + DI
            UIView.transition(with: window,
                              duration: 0.4,
                              options: .transitionFlipFromRight,
                              animations: { window.rootViewController = tab })
        } else {
            // запасной вариант, если вдруг не нашли окно
            present(TabBarController(coreDataStack: CoreDataStack(modelName: "TrackerModel")),
                    animated: true)
        }
    }
}
