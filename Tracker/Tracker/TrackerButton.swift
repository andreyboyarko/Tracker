

import UIKit

final class TrackerButton: UIButton {
    private var title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        // Заголовок
        setTitle(title, for: .normal)
        setTitleColor(UIColor(named: "ybBlack") ?? .black, for: .normal)
        setTitleColor(.white, for: .disabled)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        // Цвета по Фигме
        backgroundColor = UIColor(named: "color") ?? .systemGray5
        
        // Скругление
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        // Автолейаут
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
