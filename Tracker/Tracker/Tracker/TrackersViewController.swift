import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {

    // MARK: - Filter state
    private var currentFilter: TrackerFilter = .all {
        didSet { applyFilterAndReload() }
    }

    // MARK: - DI
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    // MARK: - Data
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []

    // MARK: - Date state
    private var selectedDate: Date = Date() {
        didSet { applyFilterAndReload() }
    }
    private var currentDate: Date = Date()
    private var dateContainer: UIView?

    // MARK: - UI
    private let searchBar = UISearchBar()
    private let dateLabel = UILabel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = cellParams.cellSpacing
        layout.minimumLineSpacing = cellParams.cellSpacing
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 50)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.identifier)
        cv.register(TrackerSectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: TrackerSectionHeader.identifier)
        return cv
    }()

    private let emptyImage = UIImageView(image: UIImage(named: "error"))
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = L10n.emptyTrackerLabel
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(named: "color") ?? .label
        l.textAlignment = .center
        return l
    }()

    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.filters, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ybBlue   // у тебя есть расширение UIColor+Hex
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // layout helper
    private let cellParams = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore,
         trackerStore: TrackerStore,
         recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("Use DI init") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = L10n.trackers
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        setupLeftPlusBold()
        setupSearchBar()
        setupCollection()
        setupEmptyState()
        setupRightDateChip()

        view.addSubview(filtersButton)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 114),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -114),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // подписки стора
        trackerStore.onChange = { [weak self] in self?.reloadFromStores() }
        recordStore.onChange  = { [weak self] in self?.reloadFromStores() }

        // восстановим выбранный фильтр из UserDefaults (как в FiltersVC)
        if let raw = UserDefaults.standard.string(forKey: FiltersViewController.trackerFilter),
           let saved = TrackerFilter(rawValue: raw) {
            currentFilter = saved
        }

        // старт
        selectedDate = Date()
        reloadFromStores()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let h = filtersButton.bounds.height
        collectionView.contentInset.bottom = h + 16
        collectionView.verticalScrollIndicatorInsets.bottom = h + 16
    }
}

// MARK: - UI setup
private extension TrackersViewController {
    func setupSearchBar() {
        searchBar.placeholder = L10n.search
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func setupCollection() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cellParams.leftInset),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -cellParams.rightInset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupEmptyState() {
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),

            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyImage.centerXAnchor)
        ])

        emptyImage.isHidden = true
        emptyLabel.isHidden = true
    }

    func setupRightDateChip() {
        let container = UIView()
        let chipBG = searchBar.searchTextField.backgroundColor ?? .systemGray5
        container.backgroundColor = chipBG
        container.layer.cornerRadius = 8
        container.layer.cornerCurve = .continuous
        container.directionalLayoutMargins = .init(top: 6, leading: 12, bottom: 6, trailing: 12)

        dateLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        dateLabel.textColor = .label
        dateLabel.text = Self.formatDate(currentDate)

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

        self.dateContainer = container
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: container)
    }

    static func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd.MM.yy"
        return df.string(from: date)
    }

    func setupLeftPlusBold() {
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
}

// MARK: - Actions
private extension TrackersViewController {
    @objc func addTrackerTapped() {
        let add = TrackerAddViewController()
        add.onTrackerAdded = { [weak self] item in
            guard let self, let tracker = item.trackers.first else { return }
            try? self.trackerStore.create(tracker, categoryTitle: item.title)
        }
        let nav = UINavigationController(rootViewController: add)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc func showInlineCalendar() {
        let vc = DatePickerViewController()
        vc.initialDate = currentDate
        vc.autoDismissOnPick = true
        vc.onPick = { [weak self] newDate in
            guard let self else { return }
            self.currentDate = newDate
            self.dateLabel.text = Self.formatDate(newDate)
            self.selectedDate = newDate
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
            pop.delegate = self
        }
        present(nav, animated: true)
    }

    @objc func filtersButtonTapped() {
        let vc = FiltersViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - Data loading & filtering
private extension TrackersViewController {
    func reloadFromStores() {
        do {
            let pairs = try trackerStore.snapshot()
            let grouped = Dictionary(grouping: pairs, by: { $0.categoryTitle })
                .map { key, value in
                    TrackerCategory(
                        title: key,
                        trackers: value.map { $0.tracker }.sorted { $0.title < $1.title }
                    )
                }
                .sorted { $0.title < $1.title }

            self.categories = grouped
            applyFilterAndReload()
        } catch {
            print("snapshot error:", error)
        }
    }

    func applyFilterAndReload() {
        // фильтрация по дню недели выбранной даты
        let weekdayIndex = Calendar.current.component(.weekday, from: selectedDate)
        let selectedWeekday = WeekdaysEnum.allCases[weekdayIndex - 1]

        var base = categories.map { cat in
            let items = cat.trackers.filter { $0.weekdays.contains(selectedWeekday) }
            return TrackerCategory(title: cat.title, trackers: items)
        }.filter { !$0.trackers.isEmpty }

        // доп. фильтр по выполненности
        switch currentFilter {
        case .all, .forToday:
            break
        case .completed:
            base = base.map { cat in
                let items = cat.trackers.filter {
                    (try? recordStore.hasRecord(for: $0.id, on: selectedDate)) ?? false
                }
                return TrackerCategory(title: cat.title, trackers: items)
            }.filter { !$0.trackers.isEmpty }
        case .uncompleted:
            base = base.map { cat in
                let items = cat.trackers.filter {
                    !((try? recordStore.hasRecord(for: $0.id, on: selectedDate)) ?? false)
                }
                return TrackerCategory(title: cat.title, trackers: items)
            }.filter { !$0.trackers.isEmpty }
        }

        filteredCategories = base

        let hasData = !filteredCategories.isEmpty
        collectionView.isHidden = !hasData
        emptyImage.isHidden = hasData
        emptyLabel.isHidden = hasData
        collectionView.reloadData()
    }

    func toggleCompletion(at indexPath: IndexPath) {
        guard selectedDate <= Date() else { return }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        do {
            if try recordStore.hasRecord(for: tracker.id, on: selectedDate) {
                try recordStore.remove(for: tracker.id, on: selectedDate)
            } else {
                try recordStore.add(TrackerRecord(trackerId: tracker.id, date: selectedDate))
            }
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("toggle record error:", error)
        }
    }
}

// MARK: - FilterViewDelegate
extension TrackersViewController: FilterViewDelegate {
    func applyOnCollection(filter: TrackerFilter) {
        currentFilter = filter
        // сохраним, чтобы FiltersVC подхватил при следующем открытии:
        UserDefaults.standard.set(filter.rawValue, forKey: FiltersViewController.trackerFilter)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { filteredCategories.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryViewOfKind kind: String,
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
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - cellParams.paddingWidth
        let width = floor(availableWidth / CGFloat(cellParams.cellCount))
        return CGSize(width: width, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleCompletion(at: indexPath)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension TrackersViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { .none }
}
