
import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - UI (твой каркас)
    private let searchField = UISearchTextField()
    private var searchTopConstraint: NSLayoutConstraint!

    // Дата (пилюля)
    private var dateContainer: UIView!
    private var dateLabel: UILabel!
    private var currentDate = Date()
    private let datePopoverDelegate = DatePopoverDelegate() // делегат для поповера
    
    
    private var coreDataStack: CoreDataStack!   // хранит стек

    // 🔹 DI через init
    init(coreDataStack: CoreDataStack) {
            self.coreDataStack = coreDataStack
            super.init(nibName: nil, bundle: nil)
        }

    required init?(coder: NSCoder) {
           super.init(coder: coder)
       }
    
    /// Поздняя инъекция на случай storyboard/xib
        func inject(coreDataStack: CoreDataStack) {
            self.coreDataStack = coreDataStack
        }
    
    // фильтр
    private let filtersButton: UIButton = {
        let b = UIButton(type: .system)
        b.configuration = nil
        b.setTitle("Фильтры", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = UIColor(named: "blue") // твой ассет
        b.layer.cornerRadius = 16
        b.layer.masksToBounds = true
        b.contentEdgeInsets = .init(top: 6, left: 20, bottom: 6, right: 20) // авто-ширина
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    // Коллекция
    private var collectionView: UICollectionView!

    // MARK: - ДАННЫЕ
    private var categories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers: [
            Tracker(id: UUID(), title: "Поливать растения", color: .ybColor3, emoji: "", weekdays: [.friday, .wednesday]),
            Tracker(id: UUID(), title: "Test 3", color: .ybColor2, emoji: "", weekdays: [.friday, .saturday]),
        ]),
        TrackerCategory(title: "Радостные мелочи", trackers: [
            Tracker(id: UUID(), title: "Кошка заслонила камеру на созвоне", color: .ybColor6, emoji: "", weekdays: [.monday, .thursday]),
            Tracker(id: UUID(), title: "Бабушка прислала открытку в вотсапе", color: .ybColor1, emoji: "", weekdays: [.monday, .wednesday]),
            Tracker(id: UUID(), title: "Test 7", color: .ybColor8, emoji: "", weekdays: [.saturday, .sunday]),
            Tracker(id: UUID(), title: "Test 5", color: .ybColor16, emoji: "", weekdays: [.friday])
        ])
    ]
    private var completedTrackers: [TrackerRecord] = []
    private var filteredCategories: [TrackerCategory] = []

    // Пустое состояние
    private var emptyStack: UIStackView!
    
    private func setupFiltersButton() {
        view.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 52),
            filtersButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Трекеры"

        setupNavBarAppearance()
        setupLeftPlus()
        setupRightDate()
        setupSearchField()
        setupEmptyState()
        setupCollectionView()
        setupFiltersButton()
        
        // Пример доступа:
        let context = coreDataStack.viewContext
        assert(coreDataStack != nil, "CoreDataStack must be injected before using TrackersViewController")
        applyFilterForCurrentDate()
    }

    // MARK: - NavBar
    private func setupNavBarAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let titleColor = UIColor(hex: "color") ?? .label

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

    // MARK: - Left: Plus
    private func setupLeftPlus() {
        let plusButton = UIButton(type: .system)
        plusButton.configuration = nil // чтобы инsets работали

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

    // MARK: - Right: пилюля даты + тап → поповер
    private func setupRightDate() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(hex: "#F0F0F0")
        container.layer.cornerRadius = 8
        container.directionalLayoutMargins = .init(top: 6, leading: 12, bottom: 6, trailing: 12)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9
        label.text = Self.formatDate(currentDate) // формат: 19.09.25

        container.addSubview(label)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 34),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 84),

            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ])

        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePicker)))

        self.dateContainer = container
        self.dateLabel = label

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: container)
    }

    @objc private func showDatePicker() {
        // Используем существующий VC
        let vc = DatePickerViewController()
        vc.initialDate = currentDate
        vc.onPick = { [weak self] newDate in
            guard let self else { return }
            self.currentDate = newDate
            self.dateLabel.text = Self.formatDate(newDate)
            self.applyFilterForCurrentDate()
        }

        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 320, height: 360)

        if let pop = vc.popoverPresentationController {
            pop.sourceView = dateContainer
            pop.sourceRect = dateContainer.bounds
            pop.permittedArrowDirections = [.up, .down]
            pop.delegate = datePopoverDelegate // чтобы не развернулся во фулл-скрин
        }

        present(vc, animated: true)
    }

    private static func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yy"
        return df.string(from: date)
    }

    // MARK: - Search field
    private func setupSearchField() {
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = UIColor(hex: "ybGray")
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

    // MARK: - Empty state
    private func setupEmptyState() {
        let img = UIImageView(image: UIImage(named: "error"))
        img.translatesAutoresizingMaskIntoConstraints = false

        let msg = UILabel()
        msg.text = "Что будем отслеживать?"
        msg.font = .systemFont(ofSize: 12, weight: .medium)
        msg.textColor = UIColor(named: "color") ?? .label
        msg.textAlignment = .center
        msg.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [img, msg])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            img.widthAnchor.constraint(equalToConstant: 80),
            img.heightAnchor.constraint(equalToConstant: 80)
        ])

        emptyStack = stack
    }

    // MARK: - Коллекция
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 9
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 50)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true // по умолчанию пусто

        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.identifier)
        collectionView.register(TrackerSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerSectionHeader.identifier)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Фильтр по выбранной дате
    private func applyFilterForCurrentDate() {
        let weekdayIndex = Calendar.current.component(.weekday, from: currentDate)
        let selectedWeekday = WeekdaysEnum.allCases[weekdayIndex - 1]

        filteredCategories = categories.compactMap { cat in
            let items = cat.trackers.filter { $0.weekdays.contains(selectedWeekday) }
            return items.isEmpty ? nil : TrackerCategory(title: cat.title, trackers: items)
        }

        let hasData = !filteredCategories.isEmpty
        collectionView.isHidden = !hasData
        emptyStack?.isHidden = hasData
        collectionView.reloadData()
    }

    // MARK: - Открываем экран выбора типа трекера
    
    @objc private func didTapAdd() {
        let add = TrackerAddViewController()

        // колбэк — как у тебя/коллеги
        add.onTrackerAdded = { [weak self] item in
            guard let self, let tracker = item.trackers.first else { return }
            if let idx = self.categories.firstIndex(where: { $0.title == item.title }) {
                var arr = self.categories[idx].trackers
                arr.append(tracker)
                self.categories[idx] = TrackerCategory(title: item.title, trackers: arr)
            } else {
                self.categories.append(item)
            }
            self.applyFilterForCurrentDate()
        }

        let nav = UINavigationController(rootViewController: add)

        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = UIColor(named: "ypBlack") ?? .systemBackground
        ap.shadowColor = .clear
        ap.titleTextAttributes = [
            .foregroundColor: UIColor(named: "color") ?? .label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        nav.navigationBar.standardAppearance = ap
        nav.navigationBar.scrollEdgeAppearance = ap
        nav.navigationBar.compactAppearance = ap
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.tintColor = UIColor(named: "color") ?? .label

        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
            sheet.largestUndimmedDetentIdentifier = .large
        }

        present(nav, animated: true)
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

// MARK: - Коллекция
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerViewCell.identifier, for: indexPath
        ) as? TrackerViewCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]

        let isCompleted = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        let count = completedTrackers.filter { $0.id == tracker.id }.count

        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompleted, count: count)
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 9
        let columns: CGFloat = 2
        let totalSpacing = spacing * (columns - 1)
        let width = collectionView.bounds.width - totalSpacing
        let cellW = floor(width / columns)
        return CGSize(width: cellW, height: cellW * 0.8)
    }
}

// MARK: - «Плюс-кружок» в карточке
extension TrackersViewController: TrackerCellDelegate {
    func didTapComplete(for tracker: Tracker) {
        // Если дата в будущем — просто ничего не делаем
        if currentDate > Date() {
            collectionView.reloadData() // обновим, чтобы кнопка осталась «+»
            return
        }

        // Если дата сегодняшняя или прошлая — работаем как раньше
        if let idx = completedTrackers.firstIndex(where: {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }) {
            completedTrackers.remove(at: idx)
        } else {
            completedTrackers.append(TrackerRecord(id: tracker.id, date: currentDate))
        }

        collectionView.reloadData()
    }
}

// Делегат только для поповера — чтобы на iPhone не стал фулл-скрином
private final class DatePopoverDelegate: NSObject, UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { .none }
}

// MARK: - HEX helper 
private extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(
            red:   CGFloat((v >> 16) & 0xFF) / 255,
            green: CGFloat((v >>  8) & 0xFF) / 255,
            blue:  CGFloat( v        & 0xFF) / 255,
            alpha: 1
        )
    }
}

