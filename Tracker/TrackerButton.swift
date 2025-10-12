

import UIKit

import UIKit

final class TrackerButton: UIButton {
    private var title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(.ybBlack, for: .normal)
        setTitleColor(.white, for: .disabled)
        titleLabel?.textColor = .ybBlack
        backgroundColor = .color
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
