import UIKit

final class CategoryCreateViewController: UIViewController {
    // MARK: - UI
    private let containerView = UIView()
    private let textField = UITextField()
    private let button = TrackerButton(title: L10n.ready)

    // MARK: - State
    private var isEnabled = false {
        didSet { button.isEnabled = isEnabled }
    }

    // MARK: - Output
    var createCategoryTapped: ((String) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = L10n.newCategory

        setupViews()
        setupLayout()
    }

    // MARK: - Setup
    private func setupViews() {
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false

        textField.delegate = self
        textField.returnKeyType = .done
        textField.placeholder = L10n.enterCategoryName
        textField.addTarget(self, action: #selector(limitLength), for: .editingChanged)
        textField.textColor = .color
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityIdentifier = "categoryTextField"

        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.isEnabled = false

        containerView.addSubview(textField)
        view.addSubview(containerView)
        view.addSubview(button)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions
    @objc private func limitLength(_ textField: UITextField) {
        let text = textField.text ?? ""
        enableButton(count: text.trimmingCharacters(in: .whitespacesAndNewlines).count)

        let maxLen = 32
        if text.count > maxLen {
            textField.text = String(text.prefix(maxLen))
        }
    }

    @objc private func createTapped() {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        createCategoryTapped?(text)
        dismiss(animated: true)
    }

    private func enableButton(count: Int) {
        let shouldEnable = count > 0
        if button.isEnabled != shouldEnable {
            button.isEnabled = shouldEnable
        }
    }
}

// MARK: - UITextFieldDelegate
extension CategoryCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createTapped()
        return true
    }
}
