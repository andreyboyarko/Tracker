import UIKit

final class StatisticsViewController: UIViewController {
    // UI
    private let emptyLabel = UILabel()
    private let emptyImage = UIImageView()
    private let tableView  = UITableView(frame: .zero, style: .plain)

    // VM
    private let viewModel: StatisticsViewModel

    // Стабильный порядок отображения секций
    private var displayedKeys: [StatisticsEnum] = []

    // MARK: - Init
    init(recordStore: TrackerRecordStore) {
        self.viewModel = StatisticsViewModel(recordStore: recordStore)
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = L10n.statistics
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        // Empty state
        emptyImage.image = UIImage(named: "emptyStatistics") ?? UIImage(named: "error")
        emptyImage.contentMode = .scaleAspectFit
        emptyImage.contentMode = .scaleAspectFit
        emptyLabel.text = L10n.emptyStatistics
        emptyLabel.textColor = .color
        emptyLabel.font = .systemFont(ofSize: 12, weight: .medium)

        // Table
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(StatisticsTableViewCell.self,
                           forCellReuseIdentifier: StatisticsTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        setupLayout()

        // VM
        viewModel.delegate = self
        viewModel.loadStatistics()
        toggleTableViewVisibility()
    }

    // MARK: - Layout
    private func setupLayout() {
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            // Пустое состояние
            emptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),

            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Таблица
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func toggleTableViewVisibility() {
        let hasData = !viewModel.statistics.isEmpty
        emptyImage.isHidden = hasData
        emptyLabel.isHidden = hasData
        tableView.isHidden  = !hasData
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // Стабильный порядок по allCases, показываем только то, что есть в словаре
        displayedKeys = StatisticsEnum.allCases.filter { viewModel.statistics[$0] != nil }
        return displayedKeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsTableViewCell.identifier,
            for: indexPath
        ) as? StatisticsTableViewCell else { return UITableViewCell() }

        let key = displayedKeys[indexPath.section]
        let value = viewModel.statistics[key] ?? "–"
        cell.configureCell(with: key.title, value: value)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 90 }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 12 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}

// MARK: - StatisticsViewDelegate
extension StatisticsViewController: StatisticsViewDelegate {
    func didUpdateData() {
        toggleTableViewVisibility()
        tableView.reloadData()
    }
}
