

import UIKit

final class NewTrackerCell: UITableViewCell {
    private let label = UILabel()
    private let arrowImage = UIImageView()
    private let stack = UIStackView()
    
    static let identifier = "NewTrackerCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .background
        
        label.font = .ypRegular
        label.textColor = .color
        
        arrowImage.image = UIImage(resource: .right)
        arrowImage.contentMode = .scaleAspectFit
        
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(arrowImage)
        contentView.addSubview(stack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func setTitle(_ title: String) {
        label.text = title
    }
}
