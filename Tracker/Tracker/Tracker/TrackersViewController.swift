
import UIKit

final class TrackersViewController: UIViewController {

    private let searchField = UISearchTextField()
    private var searchTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Трекеры"

        setupNavBarAppearance()
        setupLeftPlus()
        setupRightDate()
        setupSearchField()
        setupEmptyState()
    }

    // MARK: - NavBar (фон светлый, большой заголовок 34 Bold, цвет #1A1B22)
    private func setupNavBarAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let titleColor = UIColor(hex: "#1A1B22") ?? .label

        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .systemBackground
        ap.shadowColor = .clear
        ap.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        ap.largeTitleTextAttributes = [
            .foregroundColor: titleColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        let bar = navigationController?.navigationBar
        bar?.standardAppearance = ap
        bar?.scrollEdgeAppearance = ap
        bar?.compactAppearance = ap
        bar?.tintColor = titleColor
        bar?.isTranslucent = false
    }

    // MARK: - Left: Plus 42×42, визуальный отступ от края ≈6pt
    private func setupLeftPlus() {
        let plusButton = UIButton(type: .system)
        plusButton.configuration = nil // иначе contentEdgeInsets игнорируются
        let image = UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate)
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = .label

        plusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42)
        ])
        plusButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        plusButton.imageView?.contentMode = .center

        plusButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
    }

    // Открываем «Новую привычку» как в макете
    @objc private func didTapAdd() {
        let vc = NewTrackerCellViewController()
        vc.showSchedule = true
        // при необходимости — колбэк результата:
        // vc.onTrackerAdded = { [weak self] category in
        //     // обновить список
        // }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Right: Пилюля даты (авто-ширина, высота 34, паддинги 6/12)
    private func setupRightDate() {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yy"
        let text = df.string(from: Date())

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(hex: "#F0F0F0")
        container.layer.cornerRadius = 8
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .label
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)

        container.addSubview(label)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 34),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 84),

            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: container)
    }

    // MARK: - Search field (36pt, bg #F0F0F0, radius 10)
    private func setupSearchField() {
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = UIColor(hex: "#F0F0F0")
        searchField.layer.cornerRadius = 10
        searchField.font = .systemFont(ofSize: 17)
        searchField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchField.leftViewMode = .always
        (searchField.leftView as? UIImageView)?.tintColor = .secondaryLabel

        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false

        searchTopConstraint = searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6)
        NSLayoutConstraint.activate([
            searchTopConstraint,
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    // MARK: - Empty state ("Что будем отслеживать?")
    private func setupEmptyState() {
        let errorImage = UIImageView(image: UIImage(named: "error"))
        errorImage.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.text = "Что будем отслеживать?"
        messageLabel.font = .systemFont(ofSize: 12, weight: .medium)
        messageLabel.textColor = UIColor(hex: "#1A1B22")
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let container = UIStackView(arrangedSubviews: [errorImage, messageLabel])
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorImage.widthAnchor.constraint(equalToConstant: 80),
            errorImage.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Подгоняем отступ поиска под большой заголовок
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustSearchTopToLargeTitle()
    }

    private func adjustSearchTopToLargeTitle() {
        guard let navBar = navigationController?.navigationBar else {
            searchTopConstraint.constant = 6
            return
        }
        guard let titleLabel = findLargeTitleLabel(in: navBar) else {
            searchTopConstraint.constant = 6
            return
        }
        let labelBottomInView = navBar.convert(titleLabel.frame, to: view).maxY
        let safeTop = view.safeAreaLayoutGuide.layoutFrame.minY
        let wanted = max(0, (labelBottomInView - safeTop) + 7)
        searchTopConstraint.constant = wanted
        view.layoutIfNeeded()
    }

    private func findLargeTitleLabel(in navBar: UINavigationBar) -> UILabel? {
        func dfs(_ v: UIView) -> UILabel? {
            if let l = v as? UILabel, l.text == self.title { return l }
            for s in v.subviews { if let r = dfs(s) { return r } }
            return nil
        }
        return dfs(navBar)
    }
}

// MARK: - HEX helper
private extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(
            red: CGFloat((v >> 16) & 0xFF) / 255,
            green: CGFloat((v >> 8) & 0xFF) / 255,
            blue: CGFloat(v & 0xFF) / 255,
            alpha: 1
        )
    }
}
