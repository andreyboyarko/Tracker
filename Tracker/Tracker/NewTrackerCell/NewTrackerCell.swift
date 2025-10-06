

import UIKit

final class NewTrackerCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let arrowImage = UIImageView(image: UIImage(resource: .right))
    private let hStack = UIStackView()
    private let textStack = UIStackView()
    
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
        selectionStyle = .none
        
        // Текстовая вертикальная часть
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        
        titleLabel.font = .ypRegular
        titleLabel.textColor = .color
        
        subtitleLabel.font = .ypRegular
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.isHidden = true
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        
        // Горизонтальная часть
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .equalSpacing
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImage.contentMode = .scaleAspectFit
        
        hStack.addArrangedSubview(textStack)
        hStack.addArrangedSubview(arrowImage)
        contentView.addSubview(hStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setSubtitle(_ subtitle: String?) {
        if let subtitle = subtitle, !subtitle.isEmpty {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.isHidden = true
            subtitleLabel.text = nil
        }
    }
}
