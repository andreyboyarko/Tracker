import UIKit

final class CategoryViewController: UIViewController {
    // MARK: - VM
    private let viewModel = CategoryViewModel()

    // MARK: - UI
    private let tableView = UITableView()
    private let button = TrackerButton(title: L10n.addCategory)
    private let rowHeight: CGFloat = 75

    private let starImage: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .error))
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = L10n.emptyCategoriesLabel
        l.font = .ypMedium
        l.textColor = .color
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Constraints toggles
    private var tableHeightConstraint: NSLayoutConstraint?
    private var tableBottomConstraint: NSLayoutConstraint?

    // MARK: - State
    private var showTableView = false {
        didSet {
            starImage.isHidden = showTableView
            emptyLabel.isHidden = showTableView
            tableView.isHidden = !showTableView
        }
    }

    // MARK: - Output
    var onCategorySelected: ((String) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = L10n.category

        button.addTarget(self, action: #selector(navigateCreatePage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        viewModel.onDataFetched = { [weak self] in
            guard let self else { return }
            self.showTableView = self.viewModel.isNotEmpty()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTableHeight()
            }
        }
        viewModel.loadCategories()

        setupTableView()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // гарантируем корректную высоту после первого layout/поворотов
        updateTableHeight()
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.backgroundColor = .background
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(starImage)
        view.addSubview(emptyLabel)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            starImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Layout helpers
    private func updateTableHeight() {
        tableHeightConstraint?.isActive = false
        tableBottomConstraint?.isActive = false

        let rows = viewModel.numberOfRows()
        let totalHeight = rowHeight * CGFloat(rows)
        let maxHeight = view.bounds.height - 150 // запас под кнопку и отступы

        if totalHeight < maxHeight && viewModel.isNotEmpty() {
            tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: totalHeight)
            tableHeightConstraint?.isActive = true
        } else {
            tableBottomConstraint = tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
            tableBottomConstraint?.isActive = true
        }
        view.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func navigateCreatePage() {
        let vc = CategoryCreateViewController()
        vc.createCategoryTapped = { [weak self] title in
            guard let self else { return }
            self.viewModel.addCategory(with: title)
        }
        vc.modalPresentationStyle = .pageSheet
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { rowHeight }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath.row)
        onCategorySelected?(viewModel.titleForRow(at: indexPath.row))
        tableView.deselectRow(at: indexPath, animated: true)
        // Закрываем модалку выбора категории, если экран открыт как pageSheet
        if presentingViewController != nil {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell
        else { return UITableViewCell() }

        let title = viewModel.titleForRow(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)

        cell.configureCell(with: title, isSelected: isSelected)
        return cell
    }
}
