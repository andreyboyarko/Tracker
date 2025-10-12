

import UIKit

final class CategoryViewController: UIViewController {
    private let viewModel = CategoryViewModel()
    private let tableView = UITableView()
    private let button = TrackerButton(title: "Добавить категорию")
    private let rowHeight: CGFloat = 75
    
    private let starImage: UIImageView = {
        let image = UIImageView(image: UIImage(resource: .error))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = .ypMedium
        label.textColor = .color
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    private var tableBottomConstraint: NSLayoutConstraint?
    
    private var showTableView: Bool = false {
        didSet {
            starImage.isHidden = showTableView
            emptyLabel.isHidden = showTableView
            tableView.isHidden = !showTableView
        }
    }
    
    var onCategorySelected: ((String) -> Void)?
    
    override func viewDidLoad() {
        view.backgroundColor = .ybBlack
        navigationItem.title = "Категория"
        
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
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        
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
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func updateTableHeight() {
        tableHeightConstraint?.isActive = false
        tableBottomConstraint?.isActive = false
        
        let rows = viewModel.numberOfRows()
        let totalHeight = rowHeight * CGFloat(rows)
        let maxHeight = view.bounds.height - 150
        
        if totalHeight < maxHeight && viewModel.isNotEmpty() {
            tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: totalHeight)
            tableHeightConstraint?.isActive = true
        } else {
            tableBottomConstraint = tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
            tableBottomConstraint?.isActive = true
        }
    }
    
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

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath.row)
        onCategorySelected?(viewModel.titleForRow(at: indexPath.row))
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath)
        
        guard let cell = cell as? CategoryCell else {
            return UITableViewCell()
        }
        
        let title = viewModel.titleForRow(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        
        cell.configureCell(with: title, isSelected: isSelected)
        return cell
    }
}

