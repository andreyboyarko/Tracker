

import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    private let countLabel = UILabel()
    private let titleLabel = UILabel()
    static let identifier = "StatisticsTableViewCell"

    private let gradientBorderLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()
    private var gradientAdded = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
        setupGradientBorder()
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel.text = nil
        titleLabel.text = nil
    }

    private func setupView() {
        countLabel.font = .systemFont(ofSize: 34, weight: .bold)
        countLabel.textColor = .color
        titleLabel.font = .ypMedium
        titleLabel.textColor = .color
    }

    private func setupConstraints() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countLabel)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configureCell(with title: String, value: String) {
        countLabel.text = value
        titleLabel.text = title
    }

    private func setupGradientBorder() {
        guard !gradientAdded else { return }
        gradientAdded = true

        gradientBorderLayer.colors = [
            UIColor(hex: "#FD4C49").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#007BFA").cgColor,
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientBorderLayer.cornerRadius = 16

        borderMaskLayer.lineWidth = 2
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        gradientBorderLayer.mask = borderMaskLayer

        contentView.layer.addSublayer(gradientBorderLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = contentView.bounds
        borderMaskLayer.path = UIBezierPath(
            roundedRect: contentView.bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 16
        ).cgPath
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255,
                  blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

