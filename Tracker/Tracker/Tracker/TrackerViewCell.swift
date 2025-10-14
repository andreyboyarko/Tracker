import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapComplete(for tracker: Tracker)
}

final class TrackerViewCell: UICollectionViewCell {
    static let identifier = "TrackerViewCell"

    // MARK: - UI
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let countLabel = UILabel()
    private let button = UIButton(type: .system)

    // MARK: - State
    private var tracker: Tracker?
    weak var delegate: TrackerCellDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        tracker = nil
        emojiLabel.text = nil
        titleLabel.text = nil
        countLabel.text = nil
        cardView.backgroundColor = .clear
        button.setImage(nil, for: .normal)
        button.tintColor = nil
    }

    // MARK: - Public
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int) {
        self.tracker = tracker

        // цвет и эмодзи — только из модели
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title

        // дни (простейшая форма без склонений)
        countLabel.text = "\(count) дней"

        // плюс/галочка и её цвет
        let image = UIImage(resource: isCompleted ? .check : .plus2)
        button.setImage(image, for: .normal)
        button.tintColor = tracker.color
    }
    


    // MARK: - Actions
    @objc private func toggleDone() {
        guard let tracker else { return }
        delegate?.didTapComplete(for: tracker)
    }
}

// MARK: - Private UI
private extension TrackerViewCell {
    func setupUI() {
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .clear
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false

        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .ypMedium
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = .ypMedium
        countLabel.textColor = .color
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(toggleDone), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 17
        button.clipsToBounds = true

        contentView.addSubview(cardView)
        contentView.addSubview(countLabel)
        contentView.addSubview(button)

        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // карточка
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // title внизу карточки
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            // emoji сверху слева карточки
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),

            // счётчик и кнопка под карточкой
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 12),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            button.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
