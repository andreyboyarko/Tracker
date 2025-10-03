
import UIKit

final class NewTrackerCellViewController: UIViewController {

    // MARK: - Public API
    var onTrackerAdded: ((TrackerCategory) -> Void)?
    var showSchedule = false

    // MARK: - State
    private var trackerWeekdays: [WeekdaysEnum] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private let maxLength = 38

    // MARK: - Data (ровно 18 и 18 — 6×3)
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

    // MARK: - UI: скроллинг
    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.keyboardDismissMode = .interactive
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - UI: верх
    private let containerView = UIView()
    private let titleTextField = UITextField()
    private let clearButton = UIButton(type: .system)
    private let errorLabel = UILabel()

    // MARK: - UI: таблица «Категория/Расписание»
    private let buttonsTableView = UITableView(frame: .zero, style: .plain)
    private let buttonTitles = ["Категория", "Расписание"]

    // MARK: - UI: Emoji / Color
    private let emojiTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Emoji"
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = UIColor(named: "color") ?? .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = .zero

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        return cv
    }()

    private let colorTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Цвет"
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = UIColor(named: "color") ?? .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = .zero

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.clipsToBounds = false
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        return cv
    }()

    // MARK: - UI: нижние кнопки
    private let cancelButton = UIButton(type: .system)
    private let saveButton   = TrackerButton(title: "Сохранить")
    private let buttonStackView = UIStackView()

    // MARK: - Flags
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

    // (удалены IUO: emojiHeightC!, colorHeightC!)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybBlack
        navigationItem.title = "Новая привычка"

        setupViews()
        setupLayout()
        setupKeyboardHandling()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentInset.bottom = 24
        scrollView.scrollIndicatorInsets.bottom = 24
    }

    // MARK: - Setup
    private func setupViews() {
        // scroll
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // контейнер для TextField
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false

        titleTextField.placeholder = "Введите название трекера"
        titleTextField.addTarget(self, action: #selector(limitLength), for: .editingChanged)
        titleTextField.textColor = .color
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        clearButton.setImage(UIImage(resource: .clear), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.text = "Ограничение 38 символов"
        errorLabel.textColor = .ybRed
        errorLabel.font = .ypRegular
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        buttonsTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsTableView.backgroundColor = .background
        buttonsTableView.separatorStyle = .singleLine
        buttonsTableView.layer.cornerRadius = 16
        buttonsTableView.layer.masksToBounds = true
        buttonsTableView.isScrollEnabled = false
        buttonsTableView.delegate = self
        buttonsTableView.dataSource = self
        buttonsTableView.register(NewTrackerCell.self, forCellReuseIdentifier: NewTrackerCell.identifier)

        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor.ybRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.setTitle("Отменить", for: .normal)
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

        // hierarchy
        contentView.addSubview(containerView)
        containerView.addSubview(titleTextField)
        containerView.addSubview(clearButton)

        contentView.addSubview(errorLabel)
        contentView.addSubview(buttonsTableView)

        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollection)

        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollection)

        contentView.addSubview(buttonStackView)
    }

    private func setupLayout() {
        // фиксированные высоты секций по макету — локальные констрейнты (без IUO)
        let emojiHeightC = emojiCollection.heightAnchor.constraint(equalToConstant: 46 * 3 + 12 * 2)
        let colorHeightC = colorCollection.heightAnchor.constraint(equalToConstant: 40 * 3 + 12 * 2)

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

            // верх
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
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

            // таблица
            buttonsTableView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: showSchedule ? 150 : 75),

            // Emoji
            emojiTitleLabel.topAnchor.constraint(equalTo: buttonsTableView.bottomAnchor, constant: 24),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            emojiCollection.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 12),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiHeightC,

            // Color
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 24),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            colorCollection.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 12),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorHeightC,

            // низ
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: colorCollection.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kbWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    // MARK: - Actions
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
            showAlertError(message: "Нужно выбрать хотя бы один день недели")
            return
        }
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showAlertError(message: "Заполните название")
            return
        }
        guard let pickedEmoji = selectedEmoji else {
            showAlertError(message: "Выберите эмодзи")
            return
        }
        guard let pickedColor = selectedColor else {
            showAlertError(message: "Выберите цвет")
            return
        }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: pickedColor,
            emoji: pickedEmoji,
            weekdays: showSchedule ? trackerWeekdays : Array(WeekdaysEnum.allCases)
        )
        let category = TrackerCategory(title: "Домашний уют", trackers: [tracker])
        onTrackerAdded?(category)
        dismiss(animated: true)
    }

    private func showAlertError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Окей", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func pushSchedule() {
        let vc = NewTrackerCellScheduleViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.weekdays = trackerWeekdays
        vc.setWeekdays = { [weak self] weekdays in
            self?.trackerWeekdays = weekdays
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - Table
extension NewTrackerCellViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showSchedule && indexPath.row == 1 { pushSchedule() }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewTrackerCellViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { showSchedule ? buttonTitles.count : 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewTrackerCell.identifier,
            for: indexPath
        ) as? NewTrackerCell else { return UITableViewCell() }

        cell.setTitle(buttonTitles[showSchedule ? indexPath.row : 0])
        return cell
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
        if collectionView === emojiCollection {
            return CGSize(width: 46, height: 46)
        } else {
            return CGSize(width: 40, height: 40)
        }
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
        if collectionView === emojiCollection {
            return exactSpacing(for: collectionView, itemSide: 46)
        } else {
            return exactSpacing(for: collectionView, itemSide: 40)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

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
