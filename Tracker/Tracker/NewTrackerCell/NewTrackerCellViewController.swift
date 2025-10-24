import UIKit

final class NewTrackerCellViewController: UIViewController {

    // MARK: - Public API
    var onTrackerAdded: ((TrackerCategory) -> Void)?
    var showSchedule = false

    // MARK: - State
    private var trackerWeekdays: [Weekday] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private let maxLength = 38

    // MARK: - Edit mode
    private var isEditMode = false
    private var editInitialTracker: Tracker?
    private var editInitialCategoryTitle: String?
    private var editInitialCount: Int = 0

    // лёгкие «префилды» для редактирования
    private var trackerId: UUID?
    private var categoryName: String?
    private var daysCount: Int?

    private lazy var daysCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .color
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Data
    private let emojis: [String] = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🧊","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝","😴"
    ]

    private let colors: [UIColor] = [
        .ybColor1, .ybColor2, .ybColor3, .ybColor4, .ybColor5, .ybColor6,
        .ybColor7, .ybColor8, .ybColor9, .ybColor10, .ybColor11, .ybColor12,
        .ybColor13, .ybColor14, .ybColor15, .ybColor16, .ybColor17, .ybColor18
    ]

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let containerView = UIView()
    private let titleTextField = UITextField()
    private let clearButton = UIButton(type: .system)
    private let errorLabel = UILabel()

    private let buttonsTableView = UITableView(frame: .zero, style: .plain)
    private let buttonTitles: [String] = [L10n.category, L10n.schedule]
    private var trackerCategory: TrackerCategory?

    private let emojiTitleLabel = UILabel()
    private lazy var emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let colorTitleLabel = UILabel()
    private lazy var colorCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let cancelButton = UIButton(type: .system)
    private let saveButton   = TrackerButton(title: L10n.save)
    private let buttonStackView = UIStackView()

    private var showErrorLabel = false {
        didSet { errorLabel.isHidden = !showErrorLabel }
    }
    private var showClearButton = false {
        didSet {
            clearButton.isHidden = !showClearButton
            saveButton.isEnabled = showClearButton
            saveButton.backgroundColor = showClearButton ? .color : .ybGray
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = L10n.newTracker

        setupViews()
        setupLayout()
        applyEditPrefillIfNeeded()
        setupKeyboardHandling()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentInset.bottom = 24
        scrollView.scrollIndicatorInsets.bottom = 24
    }

    // MARK: - Keyboard
    @objc private func kbWillChange(_ n: Notification) {
        guard
            let u = n.userInfo,
            let frame = (u[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect),
            let dur = (u[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double),
            let curve = (u[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt)
        else { return }

        let endInView = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - endInView.origin.y)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: overlap, right: 0)

        UIView.animate(
            withDuration: dur,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
            }
        )
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kbWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    // MARK: - Edit Setup
    /// Вызывается из списка трекеров при долгом тапе → «Редактировать»
    func setToEdit(tracker: Tracker, of category: String, count: Int) {
        isEditMode = true
        editInitialTracker = tracker
        editInitialCategoryTitle = category
        editInitialCount = count

        trackerId = tracker.id
        categoryName = category
        selectedColor = tracker.color
        selectedEmoji = tracker.emoji
        trackerWeekdays = tracker.weekdays
        titleTextField.text = tracker.title
        daysCount = count
    }

    private func applyEditPrefillIfNeeded() {
        guard isEditMode, editInitialTracker != nil else { return }

        navigationItem.title = L10n.edit  // «Редактировать»

        if let cnt = editInitialCount as Int?, cnt > 0 {
            daysCountLabel.text = L10n.daysCount(cnt)
            daysCountLabel.isHidden = false
        }

        emojiCollection.reloadData()
        colorCollection.reloadData()
        buttonsTableView.reloadData()
    }

    // MARK: - Setup
    private func setupViews() {
        // scroll
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(daysCountLabel)

        // input container
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        titleTextField.placeholder = L10n.enterTrackerName
        titleTextField.addTarget(self, action: #selector(limitLength), for: .editingChanged)
        titleTextField.textColor = .color
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleTextField)

        clearButton.setImage(Asset.clear.image, for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(clearButton)

        errorLabel.text = L10n.errorTrackerName
        errorLabel.textColor = .ybRed
        errorLabel.font = .ypRegular
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorLabel)

        // table «Категория/Расписание»
        buttonsTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsTableView.backgroundColor = .background
        buttonsTableView.layer.cornerRadius = 16
        buttonsTableView.layer.masksToBounds = true
        buttonsTableView.isScrollEnabled = false
        buttonsTableView.delegate = self
        buttonsTableView.dataSource = self
        buttonsTableView.register(NewTrackerCell.self, forCellReuseIdentifier: NewTrackerCell.identifier)
        contentView.addSubview(buttonsTableView)

        // Emoji section
        emojiTitleLabel.text = "Emoji"
        emojiTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiTitleLabel.textColor = .color
        emojiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiTitleLabel)

        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.minimumInteritemSpacing = 12
        emojiLayout.minimumLineSpacing = 12
        emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojiCollection.backgroundColor = .clear
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        contentView.addSubview(emojiCollection)

        // Color section
        colorTitleLabel.text = L10n.color
        colorTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorTitleLabel.textColor = .color
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorTitleLabel)

        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.minimumInteritemSpacing = 12
        colorLayout.minimumLineSpacing = 12
        colorCollection = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        colorCollection.backgroundColor = .clear
        colorCollection.dataSource = self
        colorCollection.delegate = self
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        contentView.addSubview(colorCollection)

        // bottom buttons
        cancelButton.layer.cornerRadius = 16
        colorCollection.clipsToBounds = false
        colorCollection.layer.masksToBounds = false
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor.ybRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.setTitle(L10n.cancel, for: .normal)
        cancelButton.titleLabel?.font = .ypRegular
        cancelButton.setTitleColor(.ybRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        showClearButton = false

        buttonStackView.spacing = 8
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(saveButton)
        contentView.addSubview(buttonStackView)
    }

    private func setupLayout() {
        // фиксированные высоты секций (6×3 сетки)
        let emojiHeightC = emojiCollection.heightAnchor.constraint(equalToConstant: 46 * 3 + 12 * 2)
        let colorHeightC = colorCollection.heightAnchor.constraint(equalToConstant: 46 * 3 + 12 * 2)

        NSLayoutConstraint.activate([
            // scroll & content
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // top
            daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysCountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            titleTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -41),

            clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),

            // table
            buttonsTableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: showSchedule ? 150 : 75),

            // Emoji
            emojiTitleLabel.topAnchor.constraint(equalTo: buttonsTableView.bottomAnchor, constant: 24),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            emojiCollection.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 12),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiHeightC,

            // Color
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 24),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            colorCollection.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 12),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorHeightC,

            // bottom buttons
            buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: colorCollection.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])

        if trackerId != nil {
            containerView.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40).isActive = true
        } else {
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
        }
    }

    // MARK: - Actions
    @objc private func limitLength(_ textField: UITextField) {
        let text = textField.text ?? ""
        showClearButton = !text.isEmpty
        showErrorLabel = text.count > maxLength
        if showErrorLabel { textField.text = String(text.prefix(maxLength)) }
    }

    @objc private func clearTextField() {
        titleTextField.text = ""
        showErrorLabel = false
        showClearButton = false
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func saveTapped() {
        if trackerWeekdays.isEmpty && showSchedule {
            showAlertError(message: L10n.alertChooseWeekday)
            return
        }
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showAlertError(message: L10n.alertEnterTrackerName)
            return
        }
        guard let pickedEmoji = selectedEmoji else {
            showAlertError(message: L10n.alertChooseEmoji)
            return
        }
        guard let pickedColor = selectedColor else {
            showAlertError(message: L10n.alertChooseColor)
            return
        }

        // Категория: сначала из выбора на экране, иначе — из предзаполнения при редактировании
        let resolvedCategoryTitle: String? = {
            if let title = trackerCategory?.title { return title }
            if let title = categoryName { return title }
            return nil
        }()
        guard let categoryName = resolvedCategoryTitle else {
            showAlertError(message: L10n.alertChooseCategory)
            return
        }

        let finalId = trackerId ?? editInitialTracker?.id ?? UUID()

        let tracker = Tracker(
            id: finalId,
            title: title,
            color: pickedColor,
            emoji: pickedEmoji,
            weekdays: showSchedule ? trackerWeekdays : Array(Weekday.allCases)
        )

        let category = TrackerCategory(title: categoryName, trackers: [tracker])
        onTrackerAdded?(category)
        dismiss(animated: true)
    }

    private func showAlertError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.okay, style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Table
extension NewTrackerCellViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { pushCategory() }
        else if showSchedule && indexPath.row == 1 { pushSchedule() }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showSchedule ? buttonTitles.count : 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewTrackerCell.identifier,
            for: indexPath
        ) as? NewTrackerCell else {
            return UITableViewCell()
        }

        let title = buttonTitles[showSchedule ? indexPath.row : 0]
        cell.setTitle(title)

        if indexPath.row == 0 {
            // Категория
            let t = trackerCategory?.title ?? categoryName
            cell.setSubtitle(t)
        } else if showSchedule && indexPath.row == 1 {
            // Расписание
            let df = DateFormatter()
            let subtitle: String? = {
                if trackerWeekdays.isEmpty { return nil }
                if trackerWeekdays.count == 7 { return L10n.everyday }
                return trackerWeekdays
                    .sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortName(formatter: df) }
                    .joined(separator: ", ")
            }()
            cell.setSubtitle(subtitle)
        }

        return cell
    }
}

// MARK: - Category / Schedule pushes
private extension NewTrackerCellViewController {
    @objc func pushCategory() {
        let vc = CategoryViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.onCategorySelected = { [weak self] title in
            guard let self else { return }
            self.categoryName = title
            self.trackerCategory = TrackerCategory(title: title, trackers: [])
            self.buttonsTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    @objc func pushSchedule() {
        let vc = NewTrackerCellScheduleViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.weekdays = trackerWeekdays
        vc.setWeekdays = { [weak self] weekdays in
            guard let self else { return }
            self.trackerWeekdays = weekdays
            self.buttonsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - Collections
extension NewTrackerCellViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollection ? emojis.count : colors.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollection {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseId,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(emoji: emoji, selected: (emoji == selectedEmoji))
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseId,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            cell.configure(color: color, selected: (selectedColor?.cgColor == color.cgColor))
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollection {
            let newEmoji = emojis[indexPath.item]
            selectedEmoji = (selectedEmoji == newEmoji) ? nil : newEmoji
            collectionView.reloadData()
        } else {
            let newColor = colors[indexPath.item]
            selectedColor = (selectedColor?.cgColor == newColor.cgColor) ? nil : newColor
            collectionView.reloadData()
        }
    }

    // фиксированные размеры
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView === emojiCollection ? CGSize(width: 46, height: 46)
                                           : CGSize(width: 40, height: 40)
    }

    private func exactSpacing(for collectionView: UICollectionView, itemSide: CGFloat) -> CGFloat {
        let columns: CGFloat = 6
        let horizontalInsets: CGFloat = 16 + 16
        let available = collectionView.bounds.width - horizontalInsets
        let raw = (available - columns * itemSide) / (columns - 1)
        return max(0, raw)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionView === emojiCollection ? exactSpacing(for: collectionView, itemSide: 46)
                                           : exactSpacing(for: collectionView, itemSide: 40)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 12 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - Internal Cells
private final class EmojiCell: UICollectionViewCell {
    static let reuseId = "EmojiCell"

    private let selectionBg = UIView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        selectionBg.translatesAutoresizingMaskIntoConstraints = false
        selectionBg.backgroundColor = .clear
        selectionBg.layer.cornerRadius = 16
        selectionBg.layer.masksToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center

        contentView.addSubview(selectionBg)
        selectionBg.addSubview(label)

        NSLayoutConstraint.activate([
            selectionBg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionBg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionBg.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionBg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            label.centerXAnchor.constraint(equalTo: selectionBg.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: selectionBg.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(emoji: String, selected: Bool) {
        label.text = emoji
        selectionBg.backgroundColor = selected ? UIColor.systemGray5 : .clear
    }
}

private final class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"

    private let swatch = UIView()
    private let ringLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.layer.cornerRadius = 8
        swatch.layer.cornerCurve = .continuous
        swatch.layer.borderColor = UIColor.white.cgColor
        swatch.layer.borderWidth = 0

        contentView.addSubview(swatch)
        NSLayoutConstraint.activate([
            swatch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            swatch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            swatch.topAnchor.constraint(equalTo: contentView.topAnchor),
            swatch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 4
        ringLayer.isHidden = true
        ringLayer.lineJoin = .round
        ringLayer.lineCap = .round
        contentView.layer.addSublayer(ringLayer)

        contentView.layer.masksToBounds = false
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let ringRect = contentView.bounds.insetBy(dx: -2, dy: -2)
        let ringCorner: CGFloat = 10
        ringLayer.frame = contentView.bounds
        ringLayer.path = UIBezierPath(roundedRect: ringRect, cornerRadius: ringCorner).cgPath
    }

    func configure(color: UIColor, selected: Bool) {
        swatch.backgroundColor = color
        swatch.layer.borderWidth = selected ? 2 : 0
        ringLayer.strokeColor = color.withAlphaComponent(0.30).cgColor
        ringLayer.isHidden = !selected
    }
}
