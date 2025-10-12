import UIKit

final class CategoryCell: UITableViewCell {
    private let label = UILabel()
    private let checkImage = UIImageView(image: UIImage(systemName: "checkmark"))
    private let stack = UIStackView()
    
    static let identifier = "CategoryCell"
    
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
        
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(checkImage)
        contentView.addSubview(stack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
    
    func configureCell(with title: String, isSelected: Bool) {
        label.text = title
        checkImage.isHidden = !isSelected
    }
}

