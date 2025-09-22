import UIKit

final class TrackerSectionHeader: UICollectionReusableView {
    let label = UILabel()
    static let identifier = "TrackerSectionHeader"

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        addSubview(label)
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "color") ?? .label
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
