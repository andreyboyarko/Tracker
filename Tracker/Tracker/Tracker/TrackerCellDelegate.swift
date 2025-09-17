

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapComplete(for tracker: Tracker)
}

final class TrackerViewCell: UICollectionViewCell {
    private let button = UIButton(type: .system)
    private let countLabel = UILabel()
    
    static let identifier = "TrackerViewCell"
    private var tracker: Tracker?
    weak var delegate: TrackerCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int) {
        self.tracker = tracker
        let containerView = UIView()
        
        containerView.backgroundColor = tracker.color
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = tracker.title
        titleLabel.font = .ypMedium
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.text = "\(count) дней"
        countLabel.font = .ypMedium
        countLabel.textColor = .color   // ⬅️ заменил на твой кастомный цвет
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(resource: isCompleted ? .check : .plus)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(toggleDone), for: .touchUpInside)
        button.tintColor = tracker.color
        button.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        contentView.addSubview(countLabel)
        contentView.addSubview(button)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: countLabel.topAnchor, constant: -16),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            button.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func toggleDone() {
        guard let tracker else { return }
        delegate?.didTapComplete(for: tracker)
    }
}
