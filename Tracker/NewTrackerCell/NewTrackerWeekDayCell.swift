

import UIKit

final class NewTrackerWeekDayCell: UITableViewCell {
    private let label = UILabel()
    private let switcher = UISwitch()
    private let stack = UIStackView()
    
    var isOn: Bool = false {
        didSet {
            switcher.isOn = isOn
        }
    }
    var onToggle: ((WeekdaysEnum) -> Void)?
    
    static let identifier = "NewTrackerWeekDayCell"
    
    private var weekday: WeekdaysEnum?
    
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
        
        switcher.addTarget(self, action: #selector(toggleSwitch), for: .touchUpInside)
        switcher.onTintColor = .ybBlue
        
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(switcher)
        contentView.addSubview(stack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setWeekday(_ weekday: WeekdaysEnum) {
        self.weekday = weekday
        label.text = weekday.rawValue
    }
    
    @objc private func toggleSwitch() {
        if let weekday { onToggle?(weekday) }
    }
}
