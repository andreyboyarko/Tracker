

import UIKit

final class TrackerButton: UIButton {
    
    // MARK: - Init
    init(title: String,
         backgroundColor: UIColor = .systemBlue,
         titleColor: UIColor = .white,
         disabledTitleColor: UIColor = .lightGray,
         cornerRadius: CGFloat = 16) {
        
        super.init(frame: .zero)
        
        // Текст
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        setTitleColor(disabledTitleColor, for: .disabled)
        
        // Шрифт
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        // Цвета
        self.backgroundColor = backgroundColor
        
        // Скругления
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        // Автолэйаут
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
