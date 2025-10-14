import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - DI / Stores
    private let analytics: AnalyticsServiceProtocol
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    // MARK: - Data
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var searchText: String = "" { didSet { applyFiltersAndReload() } }
    private var selectedDate: Date = Date() {
        didSet {
            dateLabel.text = Self.formatDate(selectedDate)
            applyFiltersAndReload()
        }
    }
    private var activeFilter: TrackerFilter {
        get {
            if let raw = UserDefaults.standard.string(forKey: FiltersViewController.trackerFilter),
               let f = TrackerFilter(rawValue: raw) { return f }
            return .all
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: FiltersViewController.trackerFilter)
            applyFiltersAndReload()
            filtersButton.setTitleColor(newValue == .all ? .white : .ybRed, for: .normal)
        }
    }

    // MARK: - UI
    private let searchBar = UISearchBar()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 9
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .ybBlack
        return cv
    }()

    private let emptyImage = UIImageView(image: UIImage(named: "error"))
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = L10n.emptyTrackerLabel
        l.font = .ypMedium
        l.textColor = .color
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let filtersButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.filters, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .ybBlue
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Date chip (справа в навбаре)
    private let dateLabel = UILabel()
    private var dateContainer: UIView?

    // MARK: - Layout helpers
    private let cellParams = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore,
         trackerStore: TrackerStore,
         recordStore: TrackerRecordStore) {
        self.analytics = AppMetricaService.shared
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use DI init") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack

        setupNavBar()
        setupSearchBar()
        setupDateChip()
        setupCollection()
        setupEmptyState()
        setupFiltersButton()
        setupConstraints()

        // подписки
        trackerStore.onChange = { [weak self] in self?.reloadFromStores() }
        recordStore.onChange  = { [weak self] in self?.applyFiltersAndReload() }

        // дефолтный фильтр
        if UserDefaults.standard.string(forKey: FiltersViewController.trackerFilter) == nil {
            UserDefaults.standard.set(TrackerFilter.all.rawValue, forKey: FiltersViewController.trackerFilter)
        }

        reloadFromStores()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.sendEvent(.open, screen: .main, item: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.sendEvent(.close, screen: .main, item: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let h = filtersButton.bounds.height
        collectionView.contentInset.bottom = h + 16
        collectionView.verticalScrollIndicatorInsets.bottom = h + 16
    }

    // MARK: - Setup UI
    private func setupNavBar() {
        navigationItem.title = L10n.trackers
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        // жирный плюс
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium)
        let img = UIImage(systemName: "plus", withConfiguration: cfg)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 42),
            btn.heightAnchor.constraint(equalToConstant: 42)
        ])
        btn.imageView?.contentMode = .center
        btn.contentEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 10)
        btn.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }

    private func setupSearchBar() {
        searchBar.placeholder = L10n.search
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        view.addSubview(searchBar)
    }

    private func setupDateChip() {
        let container = UIView()
        let chipBG = searchBar.searchTextField.backgroundColor ?? .systemGray5
        container.backgroundColor = chipBG
        container.layer.cornerRadius = 8
        container.layer.cornerCurve = .continuous
        container.directionalLayoutMargins = .init(top: 6, leading: 12, bottom: 6, trailing: 12)

        dateLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        dateLabel.textColor = .label
        dateLabel.text = Self.formatDate(selectedDate)

        container.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 34)
        ])

        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInlineCalendar)))
        dateContainer = container
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: container)
    }

    private func setupCollection() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.identifier)
        collectionView.register(TrackerSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerSectionHeader.identifier)
        view.addSubview(collectionView)
    }

    private func setupEmptyState() {
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)
    }

    private func setupFiltersButton() {
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        view.addSubview(filtersButton)
        // цвет текста в зависимости от активного фильтра
        filtersButton.setTitleColor(activeFilter == .all ? .white : .ybRed, for: .normal)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // search
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 36),

            // collection
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cellParams.leftInset),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -cellParams.rightInset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // empty
            emptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyImage.centerXAnchor),

            // filters button
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 114),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -114),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func addTrackerTapped() {
        analytics.sendEvent(.click, screen: .main, item: .addTrack)
        let vc = TrackerAddViewController()
        vc.onTrackerAdded = { [weak self] item in
            guard let self, let tracker = item.trackers.first else { return }
            try? self.trackerStore.create(tracker, categoryTitle: item.title)
            self.reloadFromStores()
        }
        vc.modalPresentationStyle = .pageSheet
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    @objc private func filtersButtonTapped() {
        analytics.sendEvent(.click, screen: .main, item: .filter)
        let vc = FiltersViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    @objc private func showInlineCalendar() {
        let vc = DatePickerViewController()
        vc.initialDate = selectedDate
        vc.autoDismissOnPick = true
        vc.onPick = { [weak self] newDate in
            self?.selectedDate = newDate
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover
        nav.preferredContentSize = CGSize(width: 320, height: 360)
        if let pop = nav.popoverPresentationController {
            if let anchor = dateContainer {
                pop.sourceView = anchor
                pop.sourceRect = anchor.bounds
                pop.permittedArrowDirections = [.up, .down]
            } else {
                pop.barButtonItem = navigationItem.rightBarButtonItem
            }
        }
        present(nav, animated: true)
    }

    private func editTracker(at indexPath: IndexPath) {
        analytics.sendEvent(.click, screen: .main, item: .edit)
        let category = filteredCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        let vc = NewTrackerCellViewController()
        let count = (try? recordStore.count(for: tracker.id)) ?? 0
        vc.showSchedule = tracker.weekdays.count != 7
        vc.setToEdit(tracker: tracker, of: category.title, count: count)
        vc.onTrackerAdded = { [weak self] newCategory in
            guard let self, let new = newCategory.trackers.first else { return }
            try? self.trackerStore.update(new, categoryTitle: newCategory.title)
            self.reloadFromStores()
        }
        vc.modalPresentationStyle = .pageSheet
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    private func confirmDelete(at indexPath: IndexPath) {
        analytics.sendEvent(.click, screen: .main, item: .delete)
        let alert = UIAlertController(title: "", message: L10n.deleteActionSheetMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: L10n.delete, style: .destructive, handler: { [weak self] _ in
            guard
                let self,
                indexPath.section < self.filteredCategories.count,
                indexPath.item < self.filteredCategories[indexPath.section].trackers.count
            else { return }
            let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.item]
            try? self.trackerStore.delete(id: tracker.id)
            self.reloadFromStores()
        }))
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))

        if let cell = collectionView.cellForItem(at: indexPath) {
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }

    // MARK: - Data loading & filtering
    private func reloadFromStores() {
        do {
            let pairs = try trackerStore.snapshot()
            let grouped = Dictionary(grouping: pairs, by: { $0.categoryTitle })
                .map { (key, value) in
                    TrackerCategory(title: key,
                                    trackers: value.map { $0.tracker }.sorted { $0.title < $1.title })
                }
                .sorted { $0.title < $1.title }

            categories = grouped
            applyFiltersAndReload()
        } catch {
            print("snapshot error:", error)
        }
    }

    private func applyFiltersAndReload() {
        let weekdayIndex = Calendar.current.component(.weekday, from: selectedDate)
        let selectedWeekday = Weekday.allCases[weekdayIndex - 1]
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filter = activeFilter

        filteredCategories = categories.compactMap { cat in
            let filtered: [Tracker] = cat.trackers.filter { tracker in
                // по расписанию (для выбранной даты)
                let byDate = tracker.weekdays.contains(selectedWeekday)

                // по поиску
                let bySearch = text.isEmpty || tracker.title.lowercased().contains(text)

                // по состоянию завершенности (если нужно)
                var byState = true
                if filter == .completed || filter == .uncompleted {
                    let done = (try? recordStore.hasRecord(for: tracker.id, on: selectedDate)) ?? false
                    byState = (filter == .completed) ? done : !done
                }
                // для "на сегодня" — просто дата = сегодня
                if filter == .forToday {
                    let isToday = Calendar.current.isDateInToday(selectedDate)
                    if !isToday { return false }
                }

                return byDate && bySearch && byState
            }
            return filtered.isEmpty ? nil : TrackerCategory(title: cat.title, trackers: filtered)
        }

        let hasData = !filteredCategories.isEmpty
        collectionView.isHidden = !hasData
        emptyImage.isHidden = hasData
        emptyLabel.isHidden = hasData
        collectionView.reloadData()
    }

    // MARK: - Helpers
    private static func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd.MM.yy"
        return df.string(from: date)
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}

// MARK: - Collection DataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { filteredCategories.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeader.identifier,
                for: indexPath
              ) as? TrackerSectionHeader else {
            return UICollectionReusableView()
        }
        header.label.text = filteredCategories[indexPath.section].title
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerViewCell.identifier,
                for: indexPath
            ) as? TrackerViewCell
        else { return UICollectionViewCell() }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
            let isCompleted = (try? recordStore.hasRecord(for: tracker.id, on: selectedDate)) ?? false
            let count = (try? recordStore.count(for: tracker.id)) ?? 0
        
        cell.configure(with: tracker, isCompleted: isCompleted, count: count)
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - Collection Delegate + Context Menu
extension TrackersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - cellParams.paddingWidth
        let width = floor(availableWidth / CGFloat(cellParams.cellCount))
        return CGSize(width: width, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        analytics.sendEvent(.click, screen: .main, item: .track)
        guard selectedDate <= Date() else { return } // нельзя отмечать будущее
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        if (try? recordStore.hasRecord(for: tracker.id, on: selectedDate)) == true {
            try? recordStore.remove(for: tracker.id, on: selectedDate)
        } else {
            try? recordStore.add(TrackerRecord(trackerId: tracker.id, date: selectedDate))
        }
        collectionView.reloadItems(at: [indexPath])
    }

    // Долгое нажатие: меню «Редактировать / Удалить»
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            guard let self else { return UIMenu() }
            let edit = UIAction(title: L10n.edit, image: UIImage(systemName: "pencil")) { _ in
                self.editTracker(at: indexPath)
            }
            let del = UIAction(title: L10n.delete,
                               image: UIImage(systemName: "trash"),
                               attributes: .destructive) { _ in
                self.confirmDelete(at: indexPath)
            }
            return UIMenu(children: [edit, del])
        })
    }
}

// MARK: - Фильтры
extension TrackersViewController: FilterViewDelegate {
    func applyOnCollection(filter: TrackerFilter) {
        activeFilter = filter
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func didTapComplete(for tracker: Tracker) {
        // Находим indexPath по id трекера
        if let ip = indexPath(for: tracker.id) {
            // toggle completion
            if (try? recordStore.hasRecord(for: tracker.id, on: selectedDate)) == true {
                try? recordStore.remove(for: tracker.id, on: selectedDate)
            } else {
                try? recordStore.add(TrackerRecord(trackerId: tracker.id, date: selectedDate))
            }
            collectionView.reloadItems(at: [ip])
        }
    }

    private func indexPath(for id: UUID) -> IndexPath? {
        for (section, cat) in filteredCategories.enumerated() {
            if let row = cat.trackers.firstIndex(where: { $0.id == id }) {
                return IndexPath(item: row, section: section)
            }
        }
        return nil
    }
}
//
//// MARK: - Фильтры
//extension TrackersViewController: FilterViewDelegate {
//    func applyOnCollection(filter: TrackerFilter) {
//        // если используешь VM:
//        viewModel.setFilter(filter)
//
//        // если без VM — тогда обновляй свой локальный стейт:
//        // activeFilter = filter
//        // applyFiltersAndReload()
//    }
//}
