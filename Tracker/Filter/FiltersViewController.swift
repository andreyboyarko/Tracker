

import UIKit

protocol FilterViewDelegate: AnyObject {
    func applyOnCollection(filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    static let trackerFilter = "activeTrackerFilter"
    private let rowHeight: CGFloat = 75
    private let tableView = UITableView()
    private var activeFilter: TrackerFilter?
    
    weak var delegate: FilterViewDelegate?
    
    override func viewDidLoad() {
        view.backgroundColor = .ybBlack
        navigationItem.title = L10n.filters
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        fetchTrackerFilter()
        
        view.addSubview(tableView)
        setupTableView()
        setupLayout()
    }
    
    private func fetchTrackerFilter() {
        if let rawValue = UserDefaults.standard.string(forKey: FiltersViewController.trackerFilter),
           let savedFilter = TrackerFilter(rawValue: rawValue) {
            activeFilter = savedFilter
        }
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
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: rowHeight * CGFloat(TrackerFilter.allCases.count)),
        ])
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeFilter = TrackerFilter.allCases[indexPath.row]
        guard let activeFilter else { return }
        
        let selectedRawValue = activeFilter.rawValue
        UserDefaults.standard.set(selectedRawValue, forKey: FiltersViewController.trackerFilter)
        delegate?.applyOnCollection(filter: activeFilter)
        
        dismiss(animated: true)
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath)
        
        guard let cell = cell as? CategoryCell else {
            return UITableViewCell()
        }
        
        let item = TrackerFilter.allCases[indexPath.row]
        let title = item.title
        let isSelected = item == activeFilter
        
        cell.configureCell(with: title, isSelected: isSelected)
        return cell
    }
}
